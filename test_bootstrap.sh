#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# test_bootstrap.sh — Automated test suite for bootstrap.sh
# =============================================================================
# Tests all three AUTO requirements:
#   AUTO-01: Script runs without errors
#   AUTO-02: Creates all necessary symlinks
#   AUTO-03: Idempotent behavior
#
# Tests use a temporary HOME directory — no system modification.

# ---------------------------------------------------------------------------
# Test framework setup
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
BOOTSTRAP_SCRIPT="${SCRIPT_DIR}/bootstrap.sh"
PREREQ_FILE="${SCRIPT_DIR}/prerequisites.json"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Temporary directory for test isolation
TEST_HOME=""

# Color helpers
if [[ -z "${NO_COLOR:-}" ]] && [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    RESET='\033[0m'
else
    RED='' GREEN='' YELLOW='' RESET=''
fi

# ---------------------------------------------------------------------------
# Assertion helpers
# ---------------------------------------------------------------------------
assert_eq() {
    local expected="$1"
    local actual="$2"
    local msg="${3:-Values should be equal}"
    
    if [[ "$expected" == "$actual" ]]; then
        return 0
    else
        echo "  Assertion failed: $msg"
        echo "    Expected: '$expected'"
        echo "    Actual:   '$actual'"
        return 1
    fi
}

assert_file_exists() {
    local path="$1"
    local msg="${2:-File should exist}"
    
    if [[ -e "$path" ]]; then
        return 0
    else
        echo "  Assertion failed: $msg"
        echo "    Path: $path"
        return 1
    fi
}

assert_not_exists() {
    local path="$1"
    local msg="${2:-File should not exist}"
    
    if [[ ! -e "$path" ]]; then
        return 0
    else
        echo "  Assertion failed: $msg"
        echo "    Path: $path (exists)"
        return 1
    fi
}

assert_symlink() {
    local path="$1"
    local expected_target="${2:-}"
    local msg="${3:-Should be a symlink}"
    
    if [[ ! -L "$path" ]]; then
        echo "  Assertion failed: $msg"
        echo "    Path: $path (not a symlink)"
        return 1
    fi
    
    if [[ -n "$expected_target" ]]; then
        local actual_target
        actual_target=$(readlink -f "$path" 2>/dev/null || echo "")
        if [[ "$actual_target" != *"$expected_target"* ]]; then
            echo "  Assertion failed: Symlink target mismatch"
            echo "    Path: $path"
            echo "    Expected to contain: $expected_target"
            echo "    Actual: $actual_target"
            return 1
        fi
    fi
    return 0
}

assert_not_symlink() {
    local path="$1"
    local msg="${2:-Should not be a symlink}"
    
    if [[ ! -L "$path" ]]; then
        return 0
    else
        echo "  Assertion failed: $msg"
        echo "    Path: $path (is a symlink)"
        return 1
    fi
}

# ---------------------------------------------------------------------------
# Test environment setup/teardown
# ---------------------------------------------------------------------------
setup_test_env() {
    TEST_HOME=$(mktemp -d)
    mkdir -p "${TEST_HOME}/.config"
    export HOME="$TEST_HOME"
}

teardown_test_env() {
    if [[ -n "${TEST_HOME:-}" ]] && [[ -d "${TEST_HOME:-}" ]]; then
        rm -rf "$TEST_HOME"
    fi
    # Clean up any manifest in script dir
    rm -f "${SCRIPT_DIR}/.bootstrap-manifest"
}

# Cleanup on exit
trap teardown_test_env EXIT

# ---------------------------------------------------------------------------
# Test runner
# ---------------------------------------------------------------------------
run_test() {
    local test_name="$1"
    local requirement="$2"
    shift 2
    
    ((TESTS_RUN++)) || true
    
    echo -n "[....] $test_name ($requirement)"
    
    # Run test in subshell to capture failures
    if ("$@" 2>&1); then
        ((TESTS_PASSED++)) || true
        echo -e "\r[${GREEN}PASS${RESET}] $test_name ($requirement)"
        return 0
    else
        ((TESTS_FAILED++)) || true
        echo -e "\r[${RED}FAIL${RESET}] $test_name ($requirement)"
        return 1
    fi
}

# ---------------------------------------------------------------------------
# AUTO-01: Script runs without errors
# ---------------------------------------------------------------------------

test_help_flag() {
    setup_test_env
    
    # --help should exit 0
    if ! "${BOOTSTRAP_SCRIPT}" --help >/dev/null 2>&1; then
        echo "  --help did not exit 0"
        teardown_test_env
        return 1
    fi
    
    teardown_test_env
    return 0
}

test_essential_noninteractive() {
    setup_test_env
    
    # --essential --conflict=skip should exit 0
    # Note: This may fail if essential tools aren't installed, so we check exit code
    local output
    if output=$("${BOOTSTRAP_SCRIPT}" --essential --conflict=skip 2>&1); then
        teardown_test_env
        return 0
    else
        local exit_code=$?
        # Exit code 1 means missing tool prereqs (acceptable in test env)
        # Exit code 2 means missing core prereqs (jq/whiptail) - not acceptable
        if [[ $exit_code -eq 1 ]]; then
            teardown_test_env
            return 0
        fi
        echo "  Exit code: $exit_code"
        echo "  Output: $output"
        teardown_test_env
        return 1
    fi
}

test_missing_prereq_fails() {
    setup_test_env
    
    # Create a fake PATH that ONLY contains essential bash builtins, no jq
    # We need to use a minimal PATH that doesn't include jq
    local fake_path="${TEST_HOME}/empty_bin"
    mkdir -p "$fake_path"
    
    # Create fake whiptail that does nothing (so we get past that check but fail on jq)
    # Actually, we want to test missing jq specifically
    # The script checks core prereqs first, so missing jq should cause exit 2
    
    # Run with a PATH that excludes the directory containing jq
    # Find where jq is and exclude it
    local jq_path
    jq_path=$(command -v jq 2>/dev/null || echo "")
    
    local output
    if [[ -n "$jq_path" ]]; then
        # Build a PATH that excludes the directory containing jq
        local new_path=""
        local jq_dir
        jq_dir=$(dirname "$jq_path")
        
        # Split PATH and exclude jq's directory
        IFS=':' read -ra path_dirs <<< "$PATH"
        for dir in "${path_dirs[@]}"; do
            if [[ "$dir" != "$jq_dir" ]]; then
                if [[ -n "$new_path" ]]; then
                    new_path="${new_path}:${dir}"
                else
                    new_path="$dir"
                fi
            fi
        done
        
        # Run with modified PATH (no jq)
        if output=$(PATH="${fake_path}:${new_path}" "${BOOTSTRAP_SCRIPT}" --essential --conflict=skip 2>&1); then
            echo "  Should have failed with missing prereq, but succeeded"
            echo "  Output: $output"
            teardown_test_env
            return 1
        else
            local exit_code=$?
            # Should exit non-zero for missing core prerequisites
            # Exit code 2 = script's explicit check failed
            # Exit code 127 = bash couldn't find jq (also valid failure)
            if [[ $exit_code -ne 0 ]]; then
                teardown_test_env
                return 0
            else
                echo "  Expected non-zero exit code, got $exit_code"
                teardown_test_env
                return 1
            fi
        fi
    else
        # jq not installed - skip this test
        echo "  Skipped: jq not installed on system"
        teardown_test_env
        return 0
    fi
}

# ---------------------------------------------------------------------------
# AUTO-02: Creates all necessary symlinks
# ---------------------------------------------------------------------------

test_essential_symlinks_created() {
    setup_test_env
    
    # Run bootstrap with essential tools
    local output
    if ! output=$("${BOOTSTRAP_SCRIPT}" --essential --conflict=skip 2>&1); then
        local exit_code=$?
        # Skip test if essential tools not installed (exit 1)
        if [[ $exit_code -eq 1 ]]; then
            echo "  Skipped: essential tools not installed"
            teardown_test_env
            return 0
        fi
        echo "  Bootstrap failed: $output"
        teardown_test_env
        return 1
    fi
    
    # Check that at least some symlinks were created (zsh, git are common)
    local found_symlinks=0
    
    if [[ -L "${TEST_HOME}/.zshrc" ]]; then
        ((found_symlinks++)) || true
    fi
    
    if [[ -L "${TEST_HOME}/.gitconfig" ]]; then
        ((found_symlinks++)) || true
    fi
    
    if [[ -L "${TEST_HOME}/.config/nvim" ]]; then
        ((found_symlinks++)) || true
    fi
    
    if [[ $found_symlinks -lt 1 ]]; then
        echo "  No symlinks found in test HOME"
        echo "  Output: $output"
        teardown_test_env
        return 1
    fi
    
    teardown_test_env
    return 0
}

test_directory_symlink_type() {
    setup_test_env
    
    # nvim uses directory symlink type: ~/.config/nvim -> repo/nvim/.config/nvim
    local output
    if ! output=$("${BOOTSTRAP_SCRIPT}" --essential --conflict=skip 2>&1); then
        local exit_code=$?
        if [[ $exit_code -eq 1 ]]; then
            echo "  Skipped: nvim not installed"
            teardown_test_env
            return 0
        fi
        echo "  Bootstrap failed: $output"
        teardown_test_env
        return 1
    fi
    
    # Verify nvim is a directory-level symlink
    if [[ -L "${TEST_HOME}/.config/nvim" ]]; then
        local target
        target=$(readlink -f "${TEST_HOME}/.config/nvim")
        if [[ "$target" == *"nvim/.config/nvim"* ]]; then
            teardown_test_env
            return 0
        else
            echo "  nvim symlink target unexpected: $target"
            teardown_test_env
            return 1
        fi
    else
        echo "  nvim symlink not created"
        teardown_test_env
        return 1
    fi
}

test_home_dotfile_type() {
    setup_test_env
    
    # git uses home symlink type: ~/.gitconfig -> repo/git/.gitconfig
    local output
    if ! output=$("${BOOTSTRAP_SCRIPT}" --essential --conflict=skip 2>&1); then
        local exit_code=$?
        if [[ $exit_code -eq 1 ]]; then
            echo "  Skipped: git not installed"
            teardown_test_env
            return 0
        fi
        echo "  Bootstrap failed: $output"
        teardown_test_env
        return 1
    fi
    
    # Verify gitconfig is a file-level symlink in HOME
    if [[ -L "${TEST_HOME}/.gitconfig" ]]; then
        local target
        target=$(readlink -f "${TEST_HOME}/.gitconfig")
        if [[ "$target" == *"git/.gitconfig"* ]]; then
            teardown_test_env
            return 0
        else
            echo "  gitconfig symlink target unexpected: $target"
            teardown_test_env
            return 1
        fi
    else
        echo "  gitconfig symlink not created"
        teardown_test_env
        return 1
    fi
}

test_nested_symlink_type() {
    setup_test_env
    
    # local_bin uses nested/glob symlink type: ~/.local/bin/* -> repo/local_bin/.local/bin/*
    local output
    if ! output=$("${BOOTSTRAP_SCRIPT}" --essential --conflict=skip 2>&1); then
        local exit_code=$?
        if [[ $exit_code -eq 1 ]]; then
            echo "  Skipped: local_bin prerequisites not met"
            teardown_test_env
            return 0
        fi
        echo "  Bootstrap failed: $output"
        teardown_test_env
        return 1
    fi
    
    # Verify files in ~/.local/bin/ are individual symlinks
    local bin_dir="${TEST_HOME}/.local/bin"
    if [[ -d "$bin_dir" ]]; then
        local found=0
        for file in "$bin_dir"/*; do
            if [[ -L "$file" ]]; then
                local target
                target=$(readlink -f "$file")
                if [[ "$target" == *"local_bin/.local/bin"* ]]; then
                    found=1
                    break
                fi
            fi
        done
        
        if [[ $found -eq 1 ]]; then
            teardown_test_env
            return 0
        else
            echo "  No individual file symlinks found in ~/.local/bin/"
            teardown_test_env
            return 1
        fi
    else
        echo "  ~/.local/bin directory not created"
        teardown_test_env
        return 1
    fi
}

# ---------------------------------------------------------------------------
# AUTO-03: Idempotent
# ---------------------------------------------------------------------------

test_idempotency() {
    setup_test_env
    
    # Run bootstrap twice and verify filesystem state is identical
    local output1 output2
    
    if ! output1=$("${BOOTSTRAP_SCRIPT}" --essential --conflict=skip 2>&1); then
        local exit_code=$?
        if [[ $exit_code -eq 1 ]]; then
            echo "  Skipped: essential tools not installed"
            teardown_test_env
            return 0
        fi
        echo "  First run failed: $output1"
        teardown_test_env
        return 1
    fi
    
    # Capture state after first run
    local state1
    state1=$(find "${TEST_HOME}" -type l -exec readlink {} \; 2>/dev/null | sort)
    
    # Run again
    if ! output2=$("${BOOTSTRAP_SCRIPT}" --essential --conflict=skip 2>&1); then
        echo "  Second run failed: $output2"
        teardown_test_env
        return 1
    fi
    
    # Capture state after second run
    local state2
    state2=$(find "${TEST_HOME}" -type l -exec readlink {} \; 2>/dev/null | sort)
    
    # States should be identical
    if [[ "$state1" == "$state2" ]]; then
        teardown_test_env
        return 0
    else
        echo "  Filesystem state changed between runs"
        echo "  State 1: $state1"
        echo "  State 2: $state2"
        teardown_test_env
        return 1
    fi
}

test_conflict_backup() {
    setup_test_env
    
    # Create a fake file at a target location
    mkdir -p "${TEST_HOME}/.config"
    echo "fake content" > "${TEST_HOME}/.gitconfig"
    
    # Run with --conflict=backup
    local output
    if ! output=$("${BOOTSTRAP_SCRIPT}" --essential --conflict=backup 2>&1); then
        local exit_code=$?
        if [[ $exit_code -eq 1 ]]; then
            echo "  Skipped: git not installed"
            teardown_test_env
            return 0
        fi
        echo "  Bootstrap failed: $output"
        teardown_test_env
        return 1
    fi
    
    # Verify .bak exists
    if [[ ! -f "${TEST_HOME}/.gitconfig.bak" ]]; then
        echo "  Backup file not created: ${TEST_HOME}/.gitconfig.bak"
        teardown_test_env
        return 1
    fi
    
    # Verify symlink was created
    if [[ ! -L "${TEST_HOME}/.gitconfig" ]]; then
        echo "  Symlink not created after backup"
        teardown_test_env
        return 1
    fi
    
    teardown_test_env
    return 0
}

test_conflict_skip() {
    setup_test_env
    
    # Create a fake file at a target location
    echo "fake content" > "${TEST_HOME}/.gitconfig"
    
    # Run with --conflict=skip
    local output
    if ! output=$("${BOOTSTRAP_SCRIPT}" --essential --conflict=skip 2>&1); then
        local exit_code=$?
        if [[ $exit_code -eq 1 ]]; then
            echo "  Skipped: git not installed"
            teardown_test_env
            return 0
        fi
        echo "  Bootstrap failed: $output"
        teardown_test_env
        return 1
    fi
    
    # Verify original file untouched (not a symlink)
    if [[ -L "${TEST_HOME}/.gitconfig" ]]; then
        echo "  File was converted to symlink (should have been skipped)"
        teardown_test_env
        return 1
    fi
    
    # Verify content unchanged
    local content
    content=$(cat "${TEST_HOME}/.gitconfig")
    if [[ "$content" != "fake content" ]]; then
        echo "  File content was modified"
        teardown_test_env
        return 1
    fi
    
    teardown_test_env
    return 0
}

# ---------------------------------------------------------------------------
# Undo tests
# ---------------------------------------------------------------------------

test_undo() {
    setup_test_env
    
    # Run bootstrap first
    local output
    if ! output=$("${BOOTSTRAP_SCRIPT}" --essential --conflict=skip 2>&1); then
        local exit_code=$?
        if [[ $exit_code -eq 1 ]]; then
            echo "  Skipped: essential tools not installed"
            teardown_test_env
            return 0
        fi
        echo "  Bootstrap failed: $output"
        teardown_test_env
        return 1
    fi
    
    # Verify manifest exists
    if [[ ! -f "${SCRIPT_DIR}/.bootstrap-manifest" ]]; then
        echo "  Manifest not created"
        teardown_test_env
        return 1
    fi
    
    # Run undo
    if ! output=$("${BOOTSTRAP_SCRIPT}" --undo 2>&1); then
        echo "  Undo failed: $output"
        teardown_test_env
        return 1
    fi
    
    # Verify symlinks removed
    local found_symlinks=0
    for file in "${TEST_HOME}"/.gitconfig "${TEST_HOME}"/.zshrc "${TEST_HOME}"/.config/nvim; do
        if [[ -L "$file" ]]; then
            ((found_symlinks++)) || true
        fi
    done
    
    if [[ $found_symlinks -gt 0 ]]; then
        echo "  Symlinks still exist after undo"
        teardown_test_env
        return 1
    fi
    
    # Verify manifest removed
    if [[ -f "${SCRIPT_DIR}/.bootstrap-manifest" ]]; then
        echo "  Manifest still exists after undo"
        teardown_test_env
        return 1
    fi
    
    teardown_test_env
    return 0
}

test_undo_restores_backups() {
    setup_test_env
    
    # Create a fake file at a target location
    echo "original content" > "${TEST_HOME}/.gitconfig"
    
    # Run with --conflict=backup to create backup
    local output
    if ! output=$("${BOOTSTRAP_SCRIPT}" --essential --conflict=backup 2>&1); then
        local exit_code=$?
        if [[ $exit_code -eq 1 ]]; then
            echo "  Skipped: git not installed"
            teardown_test_env
            return 0
        fi
        echo "  Bootstrap failed: $output"
        teardown_test_env
        return 1
    fi
    
    # Run undo
    if ! output=$("${BOOTSTRAP_SCRIPT}" --undo 2>&1); then
        echo "  Undo failed: $output"
        teardown_test_env
        return 1
    fi
    
    # Verify backup was restored to original name
    if [[ ! -f "${TEST_HOME}/.gitconfig" ]]; then
        echo "  Original file not restored"
        teardown_test_env
        return 1
    fi
    
    # Verify content is original
    local content
    content=$(cat "${TEST_HOME}/.gitconfig")
    if [[ "$content" != "original content" ]]; then
        echo "  Restored content doesn't match original"
        echo "  Expected: original content"
        echo "  Got: $content"
        teardown_test_env
        return 1
    fi
    
    # Verify .bak file removed
    if [[ -f "${TEST_HOME}/.gitconfig.bak" ]]; then
        echo "  Backup file still exists after undo"
        teardown_test_env
        return 1
    fi
    
    teardown_test_env
    return 0
}

# ---------------------------------------------------------------------------
# Dry-run tests
# ---------------------------------------------------------------------------

test_dry_run_no_changes() {
    setup_test_env
    
    # Run with --dry-run
    local output
    if ! output=$("${BOOTSTRAP_SCRIPT}" --dry-run --essential --conflict=skip 2>&1); then
        local exit_code=$?
        if [[ $exit_code -eq 1 ]]; then
            echo "  Skipped: essential tools not installed"
            teardown_test_env
            return 0
        fi
        echo "  Dry-run failed: $output"
        teardown_test_env
        return 1
    fi
    
    # Verify NO symlinks created
    local found_symlinks=0
    for file in "${TEST_HOME}"/.gitconfig "${TEST_HOME}"/.zshrc "${TEST_HOME}"/.config/nvim; do
        if [[ -L "$file" ]]; then
            ((found_symlinks++)) || true
        fi
    done
    
    if [[ $found_symlinks -gt 0 ]]; then
        echo "  Symlinks created during dry-run"
        teardown_test_env
        return 1
    fi
    
    # Verify NO manifest written
    if [[ -f "${SCRIPT_DIR}/.bootstrap-manifest" ]]; then
        echo "  Manifest created during dry-run"
        teardown_test_env
        return 1
    fi
    
    # Verify output contains "Would link" or similar dry-run indicator
    if [[ "$output" != *"Would"* ]] && [[ "$output" != *"Dry"* ]] && [[ "$output" != *"dry"* ]]; then
        echo "  Output doesn't indicate dry-run mode"
        echo "  Output: $output"
        teardown_test_env
        return 1
    fi
    
    teardown_test_env
    return 0
}

# ---------------------------------------------------------------------------
# Main test runner
# ---------------------------------------------------------------------------
main() {
    echo "=== Bootstrap Test Suite ==="
    echo ""
    
    # AUTO-01 tests
    run_test test_help_flag "AUTO-01" test_help_flag
    run_test test_essential_noninteractive "AUTO-01" test_essential_noninteractive
    run_test test_missing_prereq_fails "AUTO-01" test_missing_prereq_fails
    
    # AUTO-02 tests
    run_test test_essential_symlinks_created "AUTO-02" test_essential_symlinks_created
    run_test test_directory_symlink_type "AUTO-02" test_directory_symlink_type
    run_test test_home_dotfile_type "AUTO-02" test_home_dotfile_type
    run_test test_nested_symlink_type "AUTO-02" test_nested_symlink_type
    
    # AUTO-03 tests
    run_test test_idempotency "AUTO-03" test_idempotency
    run_test test_conflict_backup "AUTO-03" test_conflict_backup
    run_test test_conflict_skip "AUTO-03" test_conflict_skip
    
    # Undo tests
    run_test test_undo "AUTO-03" test_undo
    run_test test_undo_restores_backups "AUTO-03" test_undo_restores_backups
    
    # Dry-run tests
    run_test test_dry_run_no_changes "AUTO-03" test_dry_run_no_changes
    
    echo ""
    echo "=== Results: ${TESTS_PASSED}/${TESTS_RUN} passed ==="
    
    if [[ $TESTS_FAILED -gt 0 ]]; then
        exit 1
    fi
    exit 0
}

main "$@"
