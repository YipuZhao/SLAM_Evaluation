function [pose_arr] = poseMsgParser(msgs_pose)

pose_arr = [];
for i=1:size(msgs_pose, 1)
  pose_tmp = [
    msgs_pose(i).Header.Stamp.seconds;
    msgs_pose(i).Pose.Position.X;
    msgs_pose(i).Pose.Position.Y;
    msgs_pose(i).Pose.Position.Z;
    msgs_pose(i).Pose.Orientation.X;
    msgs_pose(i).Pose.Orientation.Y;
    msgs_pose(i).Pose.Orientation.Z;
    msgs_pose(i).Pose.Orientation.W
    ];
  %
  pose_arr = [pose_arr; pose_tmp'];
end

end