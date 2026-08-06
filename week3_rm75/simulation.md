# simulation mission

## /joint_states 확인
/joint_states를 확인한 결과 총 8개의 관절이 나타났다. joint1~joint7은 RM75 팔의 7개 관절이고, 추가로 그리퍼 관절인 jaw_Joint1이 나타났다. 또한 name 배열의 관절 순서는 joint1부터 순서대로 정렬되어 있지 않으므로, 각 관절의 위치값을 확인할 때는 name과 position의 같은 인덱스를 대응시켜 읽어야 한다.

## move_group 노드의 구독,발행자
move_group은 /trajectory_execution_event 등의 토픽을 구독하고, /display_planned_path 등의 토픽을 발행한다. 모션 계획 요청이 들어오는 대표적인 통로는 Action Server인 /move_action이고 궤적이 나가는 통로는 /execute_trajectory 로 보인다.

## Go2,G1의 속도명령과 달리 RM75에는 왜 궤적이 흐르는가?
o2·G1과 같은 이동 로봇은 원하는 이동 방향과 속도를 계속 명령하여 움직이는 반면, RM75와 같은 매니퓰레이터는 손끝을 정확한 목표 위치와 자세로 이동시켜야 하므로 각 관절이 시간에 따라 어떻게 움직일지를 미리 계산한 궤적을 생성하여 실행한다.

## 관절 하나를 골라 추적하기
J4를 선택하여 /joint_states의 position 값을 echo로 10초동안 관찰하였다. RViz에서 목표 마커만 이동했을 때는 J4의 position 값이 변하지 않았고, Plan을 수행해도 실제 관절 상태는 그대로였다. 이후 Execute를 수행하자 J4의 position 값이 목표 자세에 따라 연속적으로 변하였다. 이를 통해 RViz의 목표 상태와 /joint_states가 나타내는 실제 현재 관절 상태가 서로 다른 데이터임을 확인하였다.

## 나만의 데이터 흐름 지도
| 데이터 | 실제 이름(토픽/액션) | 타입 | 주기(Hz)/방식 |
|---|---|---|---|
| 관절 상태 | /joint_states | sensor_msgs/JointState 토픽 | 100Hz |
| 궤적 명령 | /rm_group_controller/follow_joint_trajectory | 액션 | 액션 |
| 그리퍼 명령 | /gripper_controller/follow_joint_trajectory | 액션 | 액션 |
| 모드/에러 상태 | 없음 | - | - |

->관절과 그리퍼의 현재 상태는 /joint_states 토픽으로 지속적으로 전달되며, 팔과 그리퍼의 이동 명령은 수 초 동안 실행되는 작업이므로 FollowJointTrajectory 액션을 사용한다. demo 모드에서는 실기체의 모드 및 에러 상태 토픽은 확인되지 않았다.

## 30초 녹화
/joint_states를 약 30초 동안 joint_log rosbag으로 녹화하였다. /joint_states의 발행 주기와 녹화 시간을 이용하여 예상한 메시지 수와 ros2 bag info에서 확인한 실제 메시지 수가 유사함을 확인하였다.

## effort 필드 관찰
demo 모드의 /joint_states에서 effort는 모두 .nan으로 나타나 유효한 힘 정보가 제공되지 않았다. 실기체에서는 모터 전류 기반의 effort 추정값이 들어올 것으로 예상하며, 정지 상태에서도 중력을 버티기 위한 힘 때문에 0이 아닐 수 있고, 동작이나 외부 부하에 따라 값이 변화할 것으로 예상한다.

## MoveIt 실습
1. 마커로 목표 지정->plan: 마커로 목표자세를 지정하고 plan을 수행하여 계획된 경로를 확인했다.
2. plan-> execute: plan 성공 후 excute를 수행하니 화면의 로봇이 계획된 경로를 따라 이동했다. 
3. 같은 목표 5회 plan만 반복:잔상 경로가 매번 다른것을 확인했다.
4. scene 장애물 추가후 plan: 경로 중간에 box 장애물을 추가하니 같은 목표이지만 장애물을 피해 경로가 달라지는 것을 확인했다.
5. box를 주황색 목표 로봇과 겹치도록 옮기고 plan을 실행하면 계획에 실패한다.
6. planning 탭의 goal state에서 named target을 선택하고 plan,execute하면 미리 정의된 자세로 이동한다.
