function snd
curl https://gameapi.mugsoft.io/games/tombala/integrations/2 \
-H "content-type: Application/json" \
-d '{"id":12,"durum":'$argv[2]',"numaralar":"'$argv[1]'","key":"cmLqKfmck8@LM3KsVDX&Mn6!EvZ6FieZxAQmCYo!Nfyb$#5#zmr2p3^^78#!AtXT","kart_alim_suresi":50}'
end
