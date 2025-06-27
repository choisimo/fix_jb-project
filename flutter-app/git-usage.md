# Git & GitHub 사용법 (완전 초보자용)

이 문서는 Git과 GitHub를 처음 사용하는 팀원을 위한 기본 가이드입니다. 아래 내용만 따라하면 프로젝트 협업의 80%는 문제없이 진행할 수 있습니다.

---

## 0. 환경 설정 (PC에 딱 한 번만!)

Git 명령어를 사용하려면 먼저 내 컴퓨터에 Git 프로그램을 설치하고, 간단한 사용자 설정을 해야 합니다.

### 1-1. Git 프로그램 설치

-   **Windows:**
    1.  [git-scm.com](https://git-scm.com/download/win) 사이트에 접속하여 Git 설치 파일을 다운로드합니다.
    2.  설치 파일을 실행하고, 특별한 설정 변경 없이 계속 **'Next'** 버튼을 눌러 설치를 완료합니다.
    3.  설치가 끝나면, 시작 메뉴에서 **'Git Bash'**를 실행할 수 있습니다. 앞으로 모든 Git 명령어는 이 'Git Bash' 창에서 입력합니다.

-   **macOS:**
    1.  `Command + Space`를 눌러 Spotlight를 열고 'Terminal'을 검색하여 실행합니다.
    2.  터미널 창에 아래 명령어를 입력하고 Enter를 누릅니다.
        ```bash
        git --version
        ```
    3.  만약 Git이 설치되어 있지 않다면, 설치를 유도하는 팝업창이 뜹니다. 안내에 따라 설치를 진행합니다.

### 1-2. Git 사용자 정보 설정

Git은 누가 작업을 했는지 기록하기 위해 이름과 이메일 정보가 필요합니다. 아래 명령어를 터미널(Git Bash)에 한 줄씩 입력해서 본인의 정보를 설정해주세요.

```bash
# 본인의 GitHub 사용자 이름을 입력하세요
git config --global user.name "YourGitHubUsername"

# 본인의 GitHub 계정 이메일을 입력하세요
git config --global user.email "your.email@example.com"
```
*   이 설정은 한 번만 해두면 모든 Git 프로젝트에서 공통으로 사용됩니다.

### 1-3. 명령어 실행 환경

-   위 설정이 끝나면 이제 Git을 사용할 준비가 되었습니다.
-   **Windows 사용자는 'Git Bash'**를, **macOS 사용자는 'Terminal'**을 열어서 아래의 모든 `git` 명령어를 실행하면 됩니다.

---

## 1. 프로젝트 시작하기

### 프로젝트 복제 (Clone)
GitHub에 있는 프로젝트를 내 컴퓨터로 처음 가져올 때 딱 한 번만 사용합니다.

```bash
git clone [GitHub 저장소 주소]
```
*   `[GitHub 저장소 주소]` 에는 이 프로젝트의 GitHub URL을 붙여넣으세요.
*   예: `git clone https://github.com/user/flutter-report-app.git`
*   이 명령어를 실행하면 `flutter-report-app` 라는 이름의 폴더가 생성됩니다. 앞으로 모든 작업은 이 폴더 안에서 진행합니다.

---

## 2. 일일 작업 흐름

### 1) 작업 시작 전: 최신 코드로 업데이트 (Pull)
다른 팀원들이 작업하고 GitHub에 올린 최신 변경사항을 내 컴퓨터로 가져옵니다. **코딩을 시작하기 전에 항상 실행해서 최신 상태를 유지하는 것이 매우 중요합니다.**

```bash
git pull origin main
```
*   `main`은 기본 브랜치(branch)의 이름입니다. 다른 브랜치에서 작업하는 경우 해당 브랜치 이름을 사용합니다.

### 2) 나만의 작업 공간 만들기 (Branch)
새로운 기능을 개발하거나 버그를 수정할 때는 `main` 브랜치를 직접 수정하지 않고, 개인 작업용 브랜치를 만들어서 진행하는 것이 안전합니다.

**새 브랜치 생성 및 이동:**
```bash
git checkout -b [새 브랜치 이름]
```
*   `[새 브랜치 이름]`은 작업 내용을 알 수 있도록 정합니다. (예: `feature/login`, `fix/report-bug`)
*   예: `git checkout -b feature/add-report-page`

**기존 브랜치로 이동:**
```bash
git checkout [이동할 브랜치 이름]
```
*   예: `git checkout main`

### 3) 작업 내용 저장하기 (Add & Commit)
코드를 수정하고 기능 개발이 어느 정도 완료되면, 변경된 내용을 저장(Commit)해야 합니다.

**① 변경된 파일 선택 (Add):**
```bash
git add .
```
*   `.` (점)은 내가 수정한 모든 파일을 저장 목록에 추가하겠다는 의미입니다.

**② 변경 내용 확정 및 메시지 작성 (Commit):**
```bash
git commit -m "여기에 작업 내용 요약"
```
*   `-m`은 메시지(message)를 의미합니다.
*   큰따옴표 안에는 어떤 작업을 했는지 다른 사람이 알아보기 쉽게 요약해서 적습니다. (예: `"Feat: 로그인 UI 완성"`, `"Fix: 보고서 상세 페이지 버그 수정"`)

### 4) 내 작업을 GitHub에 올리기 (Push)
내 컴퓨터에 저장(commit)한 작업 내용을 다른 팀원들과 공유하기 위해 GitHub 서버에 업로드합니다.

```bash
git push origin [현재 내 브랜치 이름]
```
*   `[현재 내 브랜치 이름]`은 `checkout -b`로 만들었던 브랜치 이름을 적습니다.
*   예: `git push origin feature/add-report-page`

---

## 3. 기타 유용한 명령어

### 현재 상태 확인 (Status)
어떤 파일이 수정되었는지, 어떤 브랜치에서 작업 중인지 등 현재 상태를 확인할 수 있습니다. **가장 자주 사용하게 될 명령어입니다.**

```bash
git status
```

### 작업 기록 확인 (Log)
지금까지 누가, 언제, 어떤 작업을 했는지(commit 기록) 목록을 보여줍니다.

```bash
git log
```

---

## 4. 일반적인 작업 흐름 (요약)

1.  **`git pull origin main`** (최신 코드로 업데이트)
2.  **`git checkout -b feature/my-new-feature`** (내 작업 브랜치 생성)
3.  (열심히 코딩...)
4.  **`git add .`** (수정한 파일 선택)
5.  **`git commit -m "Feat: 새로운 기능 추가"`** (작업 내용 저장 및 메시지 작성)
6.  **`git push origin feature/my-new-feature`** (내 작업을 GitHub에 업로드)
7.  (GitHub 사이트에서 `Pull Request` 생성하여 팀원에게 리뷰 요청)