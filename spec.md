# StudyMon Product Specification

## 1. Overview
StudyMon은 공부 시간을 기반으로 몬스터를 성장시키는 RPG형 자기관리 앱이다.

핵심 목표:
- 공부 동기 부여
- 자기관리 습관 형성
- 게임화된 생산성 경험 제공

## 2. Core Loop
Study Start -> Focus Timer -> App Blocking -> Study Completion -> EXP Reward -> Monster Growth

## 3. Target Users
- 대학생
- 시험 준비생
- 자기관리 사용자

## 4. MVP Features
1. Authentication (Supabase Auth)
2. Study Timer (Pomodoro: 25/50/custom)
3. Study Record Storage
4. EXP System
5. Monster Growth
6. AI Daily Planner (OpenAI API)

## 5. Tech Stack
- Frontend: Flutter (Dart)
- Backend: FastAPI
- DB/Auth: Supabase (PostgreSQL)
- AI: OpenAI API

## 6. Data Models
### User
- id
- email
- created_at
- total_study_time
- total_exp

### StudySession
- id
- user_id
- start_time
- end_time
- duration
- exp_gained

### Monster
- id
- user_id
- name
- level
- exp
- required_exp

## 7. Flutter Structure
- lib/main.dart
- lib/screens/
- lib/models/
- lib/services/
- lib/widgets/

## 8. Development Roadmap
1. Authentication
2. Study Timer
3. Study Record Storage
4. EXP System
5. Monster Growth
6. AI Daily Planner

## 9. Git Workflow
- main (stable)
- feature/auth
- feature/study-timer
- feature/study-record
- feature/exp-system
- feature/monster-growth
- feature/ai-planner

작업 규칙:
- 기능은 해당 feature 브랜치에서 개발
- PR/머지로 main 반영
- 커밋 메시지는 feat/fix/chore 규칙 사용
