# Next.js 애플리케이션을 위한 다단계 빌드 Dockerfile

# 1단계: 의존성 설치 환경
FROM node:20-alpine AS deps
WORKDIR /app

# 패키지 파일 복사
COPY package.json package-lock.json* ./

# 의존성 설치
RUN npm ci --only=production

# 2단계: 빌드 환경
FROM node:20-alpine AS builder
WORKDIR /app

# 빌드 타임 환경변수 인자 선언
ARG NEXT_PUBLIC_API_BASE_URL
ARG NEXT_PUBLIC_APP_NAME

# 빌드 시점에 환경변수 설정
ENV NEXT_PUBLIC_API_BASE_URL=$NEXT_PUBLIC_API_BASE_URL
ENV NEXT_PUBLIC_APP_NAME=$NEXT_PUBLIC_APP_NAME

# 패키지 파일 복사 및 전체 의존성 설치 (빌드를 위해 devDependencies 포함)
COPY package.json package-lock.json* ./
RUN npm ci

# 소스 코드 복사
COPY . .

# Next.js 애플리케이션 빌드
RUN npm run build

# 3단계: 실행 환경
FROM node:20-alpine AS runner

# 메타데이터 라벨
LABEL maintainer="CodePlayground Team <team@codeplayground.com>"
LABEL version="1.0.0"
LABEL description="CodePlayground Frontend Service"

WORKDIR /app

# 보안을 위한 사용자 생성
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Next.js 빌드 결과 복사
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

# Entrypoint 스크립트 복사
# CRLF(\r) 줄바꿈이 섞여 있어도 LF로 정리한 뒤 실행 권한 부여
COPY docker-entrypoint.sh ./
RUN sed -i 's/\r$//' docker-entrypoint.sh \
    && chmod +x docker-entrypoint.sh

# 권한 설정
RUN chown -R nextjs:nodejs /app
USER nextjs

# 포트 노출
EXPOSE 3000

# 환경 변수 설정
ENV PORT=3000
ENV NODE_ENV=production
ENV HOSTNAME="0.0.0.0"

# 헬스체크 설정
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD node healthcheck.js

# 엔트리포인트 설정
ENTRYPOINT ["./docker-entrypoint.sh"]

# 애플리케이션 실행
CMD ["node", "server.js"]
