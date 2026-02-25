# infra-ansible 사용 가이드 (한국어)

이 문서는 초보자 기준으로, 이 저장소를 실제 서버에서 재사용 가능하게 쓰는 방법을 설명합니다.

## 1. 이 프로젝트의 목적

이 저장소의 역할은 한 줄로 정리하면 아래와 같습니다.

- Ansible = 설치/구성 자동화 레이어

즉, Hadoop/Spark/Hive/Kafka 같은 구성요소를 사람이 매번 수동 설치하지 않고, 같은 방식으로 반복 설치할 수 있게 만듭니다.

이전 대화에서 정리한 전체 전략 관점:
- `infra-ansible` = 서버/클러스터 기반 설치와 초기 세팅
- `platform-gitops` = 쿠버네티스 배포/운영 자동화(GitOps)

두 저장소는 경쟁이 아니라 역할 분리입니다.

## 2. Ansible 구조 설명

아래 구조가 핵심입니다.

```text
infra-ansible/
├── ansible/
│   ├── ansible.cfg
│   ├── site.yml
│   ├── ARTIFACTS.md
│   ├── group_vars/
│   │   └── all.yml
│   ├── inventory/
│   │   └── hosts.ini.example
│   ├── playbooks/
│   │   ├── pipeline_demo.yml
│   │   └── validate_stack.yml
│   └── roles/
│       ├── common/
│       ├── java/
│       ├── hadoop/
│       ├── hive/
│       ├── spark/
│       ├── kafka/
│       ├── impala/
│       ├── iceberg/
│       ├── stack_validation/
│       ├── pipeline_demo/
│       ├── kubeadm/
│       └── argocd/
├── scripts/
│   ├── run-ansible.sh
│   ├── validate-stack.sh
│   └── run-pipeline-demo.sh
└── Makefile
```

파일/디렉토리 역할:
- `ansible/site.yml`
  - 메인 플레이북입니다.
  - Hadoop 생태계 설치와 (선택) K8s/bootstrap role이 순서대로 실행됩니다.
- `ansible/group_vars/all.yml`
  - 전역 변수 중심 파일입니다.
  - 버전, 설치 경로, 서비스 on/off를 여기서 조절합니다.
- `ansible/inventory/hosts.ini.example`
  - 호스트 그룹 템플릿입니다.
  - 실제 사용 시 `hosts.ini`로 복사해서 서버 정보를 채웁니다.
- `ansible/roles/*`
  - 설치 단위를 role로 분리했습니다.
  - 예: Spark 버전만 바꾸거나 Kafka만 수정해도 해당 role만 관리하면 됩니다.
- `scripts/*.sh` + `Makefile`
  - 자주 쓰는 ansible 명령을 짧게 실행할 수 있게 래핑합니다.

간단 예시:
- Hadoop만 바꾸고 싶으면 `ansible/roles/hadoop/` 중심으로 수정
- Spark 설정만 조정하고 싶으면 `ansible/roles/spark/templates/`만 수정

## 3. 이 저장소 사용법 (초보자용)

## 3-1. 사전 준비

컨트롤 노드(Ansible 실행 머신):
- Python 3
- Ansible (`ansible-playbook` 명령 가능해야 함)
- SSH 키

타겟 서버:
- Ubuntu 22.04 또는 24.04 권장
- SSH 접속 가능
- sudo 가능 계정

## 3-2. 인벤토리 설정

1) 파일 생성:

```bash
cp ansible/inventory/hosts.ini.example ansible/inventory/hosts.ini
```

2) `ansible/inventory/hosts.ini` 수정:
- `ansible_user`
- `ansible_ssh_private_key_file`
- 그룹별 서버 목록(`hadoop_namenode`, `hadoop_datanode`, `hadoop_edge` 등)

단일 서버 테스트 예시:

```ini
[hadoop_namenode]
node1 ansible_host=YOUR_SERVER_IP

[hadoop_datanode]
node1 ansible_host=YOUR_SERVER_IP

[hadoop_edge]
node1 ansible_host=YOUR_SERVER_IP

[kafka_broker]
node1

[kafka_zookeeper]
node1

[pipeline_runner]
node1

[hadoop:children]
hadoop_namenode
hadoop_datanode
hadoop_edge
kafka_broker
kafka_zookeeper
pipeline_runner

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/id_rsa
ansible_become=true
```

## 3-3. 아티팩트 준비 방식 (중요)

이 저장소는 인터넷 다운로드를 하지 않습니다.

원칙:
- 타겟 서버의 로컬 경로에 미리 파일을 배치
- 기본 루트: `/opt/artifacts`

예시 경로:
- `/opt/artifacts/hadoop/*.tar.gz|*.tgz`
- `/opt/artifacts/hive/*.tar.gz|*.tgz`
- `/opt/artifacts/spark/*.tar.gz|*.tgz`
- `/opt/artifacts/kafka/*.tar.gz|*.tgz`
- `/opt/artifacts/iceberg/*.jar`
- `/opt/artifacts/impala/*.deb` (Impala 사용 시)

버전 선택 로직:
- 변수에 `3.3.6`처럼 적어도 내부 매칭은 `major.minor` 기준 (`3.3`)
- 같은 계열이 여러 개면 `sort -V`로 가장 높은 patch 선택

예:
- `hadoop_version: "3.3.1"`이어도
- 로컬에 `hadoop-3.3.4`, `hadoop-3.3.6`이 있으면
- `hadoop-3.3.6`을 자동 선택

## 3-4. 실제 실행 순서

```bash
make ansible-plan
make ansible-apply
make validate-stack
```

의미:
- `ansible-plan`: dry-run(변경 예정 확인)
- `ansible-apply`: 설치/구성/서비스 기동 적용
- `validate-stack`: 포트/핵심 명령 체크

## 3-5. 버전/경로/토글 변경 방법

기본 수정 파일:
- `ansible/group_vars/all.yml`

자주 바꾸는 항목:
- 버전: `hadoop_version`, `hive_version`, `spark_version`, `kafka_version`, `iceberg_version`
- 아티팩트 루트: `local_artifact_root`
- 설치 루트: `stack_root`
- 서비스 시작 여부:
  - `start_hadoop_services`
  - `start_hive_services`
  - `start_spark_services`
  - `start_kafka_services`
  - `start_impala_services`
- Impala 활성화 여부:
  - `impala_enabled`

주의:
- Ubuntu 24.04에서는 Impala 패키지 호환 이슈가 있어서 기본값이 `impala_enabled: false`입니다.

## 3-6. Ansible 실행 필수 조건 체크

아래가 안 맞으면 실패가 납니다.

- 컨트롤 노드에서 `ansible-playbook` 실행 가능
- 인벤토리의 SSH 키 경로가 실제 파일과 일치
- sudo 비밀번호 요구 환경이면 `--ask-become-pass` 또는 NOPASSWD 설정
- 타겟 서버의 `/opt/artifacts/...` 파일 배치 완료

## 4. 구성 완료 후 데모 파이프라인 실행

실행:

```bash
make pipeline-demo
```

현재 데모 시나리오:
- Kafka에 샘플 이벤트 적재
- Kafka 소비 데이터를 HDFS raw 경로에 저장
- Spark가 데이터를 정제해 curated Parquet 생성
- Hive 메타스토어에 테이블 생성/조회
- SQL 검증 수행

데모 데이터 필드 예시:
- `event_id`
- `user_id`
- `amount`
- `event_time`

파이프라인 흐름:
- `Kafka -> HDFS(raw) -> Spark(transform) -> Hive(validate)`

중요:
- 지금 파이프라인은 "동작 이해/검증" 목적의 샘플입니다.
- 실제 업무 파이프라인에서는 `pipeline_demo` role 템플릿을 기반으로 입력/변환/검증 로직을 바꿔 재사용하면 됩니다.

## 운영 시 권장 패턴

- 설치/구성 자동화는 계속 `infra-ansible`에서 관리
- 배포/운영 자동화는 `platform-gitops`에서 관리
- 변경은 role 단위로 작게 나누고, 버전/경로는 `group_vars/all.yml`에서 통제
- 신규 환경도 같은 절차로 재현

## 신규 환경 투입 체크리스트

아래 항목을 위에서부터 체크하면, 신규 서버에서도 실패 확률을 크게 줄일 수 있습니다.

- [ ] `ansible-playbook`이 컨트롤 노드에서 실행된다 (`ansible-playbook --version`)
- [ ] 저장소 최신 상태를 받았다 (`git pull --ff-only origin main`)
- [ ] `hosts.ini`를 환경에 맞게 작성했다 (`ansible_user`, `ansible_ssh_private_key_file`, 호스트 그룹)
- [ ] SSH 접속이 키 기반으로 정상 동작한다 (`ansible -i ansible/inventory/hosts.ini all -m ping`)
- [ ] sudo 권한 정책을 확인했다 (필요 시 `--ask-become-pass` 또는 NOPASSWD)
- [ ] 타겟 서버에 `/opt/artifacts/...` 아티팩트가 모두 준비되어 있다
- [ ] `ansible/group_vars/all.yml`의 버전/경로/서비스 토글을 환경에 맞게 조정했다
- [ ] 적용 전 dry-run을 수행했다 (`make ansible-plan`)
- [ ] 실제 설치/구성을 적용했다 (`make ansible-apply`)
- [ ] 포트/기본 동작 검증을 통과했다 (`make validate-stack`)
- [ ] 데모 파이프라인을 한 번 실행해 데이터 흐름을 확인했다 (`make pipeline-demo`)

최종 통과 기준:
- `make ansible-apply` 실패 없음
- `make validate-stack` 실패 없음
- `make pipeline-demo` 실패 없음

## 자주 발생하는 오류와 빠른 해결

- `ansible-playbook: command not found`
  - 컨트롤 노드에 Ansible 설치 필요
- `Missing sudo password`
  - `ansible_become` 환경 점검, 필요 시 비밀번호 옵션 사용
- `No ... artifact matching major.minor=...`
  - `/opt/artifacts/<component>` 경로/파일명/버전 계열 확인
- Hive CLI 관련 Java 11 예외
  - 데모 검증은 `hive` CLI 대신 `beeline` 경로를 기본 사용하도록 반영됨

## 한 번에 기억할 핵심 3줄

- 이 저장소는 "설치/구성 자동화 레이어"입니다.
- 아티팩트는 타겟 서버 로컬에 미리 준비해야 합니다.
- 설정은 `group_vars/all.yml`, 실행은 `make ansible-apply -> make validate-stack -> make pipeline-demo` 순서로 진행하면 됩니다.
