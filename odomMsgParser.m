function [pose_arr] = odomMsgParser(msgs_odm)

pose_arr = [];
for i=1:size(msgs_odm, 1)
  pose_tmp = [
    msgs_odm{i}.Header.Stamp.seconds;
    msgs_odm{i}.Pose.Pose.Position.X;
    msgs_odm{i}.Pose.Pose.Position.Y;
    msgs_odm{i}.Pose.Pose.Position.Z;
    msgs_odm{i}.Pose.Pose.Orientation.X;
    msgs_odm{i}.Pose.Pose.Orientation.Y;
    msgs_odm{i}.Pose.Pose.Orientation.Z;
    msgs_odm{i}.Pose.Pose.Orientation.W
    ];
  %
  pose_arr = [pose_arr; pose_tmp'];
end

end