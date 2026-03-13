import { join } from "path";
console.log("import.meta.dirname:", import.meta.dirname);
console.log("Resolved path:", join(import.meta.dirname, "../../test-data-stdio"));
