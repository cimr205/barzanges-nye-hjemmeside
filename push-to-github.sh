#!/bin/bash
# ================================================
# Kør dette script lokalt på din Mac for at
# pushe alle filer til GitHub
# ================================================
# Krav: git installeret + SSH-nøgle til GitHub

echo "🚀 Pusher filer til barzanges-nye-hjemmeside..."

git init
git remote add origin git@github.com:cimr205/barzanges-nye-hjemmeside.git 2>/dev/null || git remote set-url origin git@github.com:cimr205/barzanges-nye-hjemmeside.git

git add README.md .env.example .gitignore supabase-seed.sql
git commit -m "Initial setup: CarAPI + Lovable + Supabase struktur"

git branch -M main
git push -u origin main

echo "✅ Færdig! Tjek: https://github.com/cimr205/barzanges-nye-hjemmeside"
