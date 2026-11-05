# DEC Cloud Sync 배포 안내

## 구성
- `index.html`: 기존 DEC 앱 + Supabase 로그인/동기화
- `manifest.webmanifest`, `dec-icon.svg`: PWA 설치 정보 및 아이콘
- `sw.js`: 정적 앱 파일 오프라인 캐시
- `supabase_setup.sql`: 필요한 테이블, RLS, Realtime 설정

## 1. Supabase 준비
1. Supabase 프로젝트 생성
2. Authentication > Sign In / Providers > Email에서 Email provider 활성화
3. Authentication 설정에서 **Confirm email을 OFF**로 설정 (이메일 인증 없이 가입)
4. SQL Editor에서 `supabase_setup.sql` 전체 실행
5. Project Settings > API에서 Project URL과 Publishable key(또는 anon key) 확인
   - Secret key / service_role key는 절대 브라우저에 입력하거나 공개하지 마세요.

## 2. Cloudflare Pages 배포
1. Cloudflare Dashboard > Workers & Pages > Create > Pages
2. Direct Upload 방식으로 새 프로젝트 생성
3. 이 폴더 안의 파일 5개를 모두 업로드하거나, ZIP을 압축 해제한 폴더를 배포
4. 배포된 `https://...pages.dev` 주소 접속

## 3. PC와 모바일 연결
1. PC에서 DEC 접속 > 클라우드 버튼 > Project URL과 Publishable/anon Key 저장
2. 로그인 > 회원가입 (이메일 인증 없이 가입)
3. Galaxy 모바일에서 동일한 Pages 주소 접속
4. 모바일에서도 같은 Supabase URL과 Key 설정
5. 동일한 이메일/비밀번호로 로그인
6. 이후 문장 및 날짜별 링크 저장은 클라우드에 반영되고, 다른 기기 화면은 Realtime으로 갱신됩니다.

## 4. 기존 로컬 데이터
첫 로그인 시 기존 브라우저에 저장된 DEC 문장 및 날짜별 링크를 해당 계정으로 한 번 이전합니다.
계정별 캐시는 분리됩니다. 다른 계정으로 로그인하면 이전 계정의 로컬 캐시를 불러오지 않습니다.

## 5. 참고
- PC와 모바일은 반드시 동일한 Supabase 프로젝트와 동일한 사용자 계정을 사용해야 합니다.
- 데이터베이스 접근은 RLS 정책으로 로그인한 본인 데이터만 허용합니다.
- 브라우저 캐시/기기 저장공간 삭제, 앱 데이터 삭제 전에는 클라우드 동기화가 완료됐는지 확인하세요.
- 오프라인 중 변경한 문장은 다음에 온라인 상태에서 동기화 버튼을 누르면 업로드되도록 대기열에 기록됩니다.
- PWA 설치 메뉴는 브라우저/기기에 따라 자동 표시되지 않을 수 있습니다. Chrome 메뉴의 '앱 설치' 또는 '홈 화면에 추가'를 이용할 수 있습니다.
