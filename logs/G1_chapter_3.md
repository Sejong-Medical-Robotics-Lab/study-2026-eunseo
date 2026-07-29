# G1 chapter 3 

## 미션 1 - 환경 준비와 첫 탐사
- low state에 담긴 관절데이터는 29개, 각 관절에는 q(각도), dq(각속도), tau(토크), temperature(온도) 값이 있었다.
 
- 휴머노이드는 무게 중심이 높고 지지영역이 좁아 작은 기울어짐에도 빠르게 커질 수 있기 때문에 제어기 상태를 자주 확인하고 균형 보정이 필요하다.

- ROS2는 DDS를 사용해 같은 네트워크에 있는 노드와 토픽을 자동으로 발견한다. 그래서 실습실에서 여러조가 동시에 ROS2를 실행하면 다른 조의 노드와 토픽까지 발견되어 데이터가 섞일 수 있다. 그래서 ROS_DOMAIN_ID를 설정해야한다.

## 미션 2 - 관절 하나 추적하기

- 선택 관절: left_ankle_pitch_joint 

## 미션 3 - 나만의 데이터 흐름 지도

| 데이터 | 실제 토픽/채널 이름 | 타입 | 주기(Hz) |
|---|---|---|---|
| low state | /g1/lowstate | g1_edu_interfaces/msg/LowState | 50Hz |
| 모션/보행 명령 | SDK 경로 | python API 호출 | 명령 호출 시 |
| 모드/상태 보고 | /g1/mode | g1_edu_interfaces/msg/ModeState | 10Hz |

## 미션 4 - 30초 녹화
주기: 50Hz
duration: 약 33초
메시지 수: 1644
50 x 33 = 1650로 1644와 비슷하게 나왔다.


