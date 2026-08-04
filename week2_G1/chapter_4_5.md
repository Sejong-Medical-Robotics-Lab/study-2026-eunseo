# 학습일지 2026-07-29

## 자율학습 미션 A

### 환경 준비와 첫 탐사 - 조사 질문
- low state에 담긴 관절 데이터: 29개, 다리 12개 + 허리 3개 + 팔 14개로 총 29개/ 각 관절에 q(속도), dq(각속도), tau(토크), temperature(온도) 값이 있다.
- 휴머노이드는 무게 중심이 높고 지지영역이 좁아 작은 기울어짐에도 빠르게 커질 수 있기 때문에 제어기 상태를 자주 확인하고 균형 보정이 필요하다.
- ROS2는 DDS를 사용해 같은 네트워크에 있는 노드와 토픽을 자동으로 발견한다. 그래서 실습실에서 여러조가 동시에 ROS2를 실행하면 다른 조의 노드와 토픽까지 발견되어 데이터가 섞일 수 있다. 그래서 ROS_DOMAIN_ID를 설정해야한다.

### 나만의 데이터 흐름 지도
| 데이터 | 실제 토픽/채널 이름 | 타입 | 주기(Hz) |
|---|---|---|---|
| low state | /g1/lowstate | g1_edu_interfaces/msg/LowState | 50Hz |
| 모션/보행 명령 | SDK 경로 | python API 호출 | 명령 호출 시 |
| 모드/상태 보고 | /g1/mode | g1_edu_interfaces/msg/ModeState | 10Hz |

### 30초 녹화
주기: 50Hz
duration: 약 33초
메시지 수: 1644
50 x 33 = 1650로 1644와 비슷하게 나왔다.

## 4장 자율학습

### 파라미터 목록
| 이름 | 기본값 | 추정 의미 |
|---|---|---|
| vx | 0.1 | 전진 속도 |
| vy | 0.0 | 좌우 이동 속도 |
| vyaw | 0.0 | 회전 속도 |
| step_period | 0.45 | 걸음 주기 |
| step_height | 0.07 | 유각 발 들어올림 높이 |
| com_shift | 0.045 | 좌우 무게중심 이동 폭 |
| pelvis_height | 0.755 | 보행 중 골반 높이 |
| arm_swing | 0.12 | 보행 중 팔 스윙 진폭 |

## 자율 학습 미션 B

### 예제 해부
- Damp -> 기립 준비,전이 -> 기립,균형 상태 -> 손 흔들기 모션 -> 기립,균형 상태(복귀) -> Damp -> 종료
- 이전 명령에 따른 상태 전이가 완료할 시간을 확보하기 위해 각 전이 사이에 sleep이 있다.
- 중간에 ctrl+c로 중단되면 finally가 실행되어 Damp가 호출되고 시뮬레이터가 종료된다. 일반적으로 python 에서 ctrl+c를 누르면 keyboardinterrupt가 발생한다. 이때 이것은 exception의 하위 클래스가 아니라 baseexception 계열이라 exception Exception as e에 잡히지 않아 finally가 실행되는 것이다.

### 실패 경로 추적
가. 기립 전이 중 오류 발생하면 except에서 오류 출력한 뒤 finally 실행되어 Damp 호출하고 종료된다.
나. 모션 실행 중 ctrl+c로 중단되면 finally 실행되어 Damp 호출되고 종료된다.
다. 통신 끊기면 finally 실행되지만 Damp 호출이 안될 수도 있다.

### 시뮬레이션 검증 기록
- 예측한 전이 순서대로 화면의 로봇이 움직인다.
- 팔 모션 중 하체와 허리가 미세하게 움직인다.
- 모션 중 ctrl+c를 누르면 시뮬레이터가 종료된다.

### 나만의 시퀀스 설계안
|순서 | 명령 | 대기(초/조건) | 기대 상태 | 실패 시 경로 |
|---|---|---|---|---|
| 1 | Damp() | 1초 | 힘 빠짐 | 종료 |
| 2 | StandUp() | 30초(balance_stand) | 기립,균형 상태 | Damp() |
| 3 | PlayAction("wave") | 동작 완료될 때까지 | 손 흔들기 | Damp() |
| 4 | PlayAction("hands_up") | 동작 완료될 때까지 | 양손 들기 | Damp() |
| 5 | PlayAction("bow") | 동작 완료될때까지 | 허리 숙여 인사하기 | Damp() |
| 6 | Damp() | 1초 | 알려진 안전 상태 | 종료 |

### 도전 미션의 상태 기반 대기 의사코드
examples/02_wave_demo.py 에서 

print(f"동작 재생: wave")
client.PlayAction("wave")
while client.ActionActive()
   time.sleep(0.1 * z())
time.sleep(1.0 * z())

print("동작 재생: hands_up")
client.PlayAction("hands_up")
while client.ActionActive()
   time.sleep(0.1 * z())
time.sleep(1.0 * z())

print(f"동작 재생: bow")
client.PlayAction("bow")
while client.ActionActive()>
   time.sleep(0.1 * z())
time.sleep(1.0 * z())
이 코드를 추가하였다.
