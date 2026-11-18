#!/usr/bin/env bash
# 중국어 퀴즈 사이트 배포 스크립트
# 사용법: bash deploy.sh <owner/repo>  예) bash deploy.sh whrmafks1-afk/zhongwen-work-quiz
set -euo pipefail

REPO="${1:?사용법: bash deploy.sh owner/repo}"
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

git config user.name  "whrmafks1-afk"
git config user.email "whrmafks1-afk@users.noreply.github.com"

git add -A
if ! git diff --cached --quiet; then
  git commit -q -m "중국어 한입 퀴즈: 에디토리얼 리뉴얼 (발음 듣기·컨페티·오답 복습·마켓 링크)"
fi
git branch -M main

# 원격이 없으면 추가
if ! git remote get-url origin >/dev/null 2>&1; then
  git remote add origin "https://github.com/${REPO}.git"
fi

git push -u origin main

# GitHub Pages 활성화 (이미 켜져 있으면 갱신)
gh api -X POST "repos/${REPO}/pages" \
  -f "source[branch]=main" -f "source[path]=/" 2>/dev/null \
  || gh api -X PUT "repos/${REPO}/pages" \
     -f "source[branch]=main" -f "source[path]=/" 2>/dev/null \
  || gh api -X POST "repos/${REPO}/pages/builds" >/dev/null 2>&1 || true

echo "pushed: https://github.com/${REPO}"
