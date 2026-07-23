F=~/robot_study/study-2026-eunseo/env_report.md
{
 echo "# 내 개발환경 리포트 ($(date +%F))"
 echo "- OS: $(lsb_release -ds)"
 echo "- 커널: $(uname -r)"
 echo "- CPU 코어: $(nproc), 메모리: $(free -h | awk '/Mem/{print $2}')"
 echo "- 디스크 여유: $(df -h / | awk 'NR==2{print $4}')"
 echo "- Python: $(python3 --version 2>&1)"
} > $F
cat $F

