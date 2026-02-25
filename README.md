# infra-ansible

Hadoop 에코시스템 설치/구성 자동화용 Ansible 저장소입니다.

핵심 목적:
- 설치/구성/서비스 기동을 반복 가능하게 자동화
- 서버를 다시 만들어도 같은 방식으로 재현 가능
- 사용자의 수동 개입 최소화

## 문서

- 초보자용 전체 가이드: [`docs/USAGE_KO.md`](docs/USAGE_KO.md)
- 아티팩트 규칙: [`ansible/ARTIFACTS.md`](ansible/ARTIFACTS.md)

## 빠른 실행

1. 인벤토리 복사
   - `cp ansible/inventory/hosts.ini.example ansible/inventory/hosts.ini`
2. `hosts.ini` 수정
3. 설치 적용
   - `make ansible-apply`
4. 상태 검증
   - `make validate-stack`
5. 데모 파이프라인 실행
   - `make pipeline-demo`

## 명령어 요약

- `make ansible-plan`: 전체 dry-run
- `make ansible-apply`: 전체 설치/구성 적용
- `make validate-stack`: 포트/핵심 명령 기반 상태 검증
- `make pipeline-demo`: Kafka -> HDFS -> Spark -> Hive 데모 실행
