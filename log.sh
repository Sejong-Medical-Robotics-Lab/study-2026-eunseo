F=logs/$(date +%F).md
mkdir -p logs
if [ ! -f $F ]; then
printf '# 학습일지 %s\n## 오늘 배운 것\n-\n##막힌 것\n-\n' $(date +%F) > $F
fi
nano $F

