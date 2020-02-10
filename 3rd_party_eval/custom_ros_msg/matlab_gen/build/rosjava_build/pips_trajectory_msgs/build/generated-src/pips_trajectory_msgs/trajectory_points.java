package pips_trajectory_msgs;

public interface trajectory_points extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "pips_trajectory_msgs/trajectory_points";
  static final java.lang.String _DEFINITION = "Header header\ntrajectory_point[] points\n";
  static final boolean _IS_SERVICE = false;
  static final boolean _IS_ACTION = false;
  std_msgs.Header getHeader();
  void setHeader(std_msgs.Header value);
  java.util.List<pips_trajectory_msgs.trajectory_point> getPoints();
  void setPoints(java.util.List<pips_trajectory_msgs.trajectory_point> value);
}
