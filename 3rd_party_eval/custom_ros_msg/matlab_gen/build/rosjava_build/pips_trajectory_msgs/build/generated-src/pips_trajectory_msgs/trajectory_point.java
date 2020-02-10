package pips_trajectory_msgs;

public interface trajectory_point extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "pips_trajectory_msgs/trajectory_point";
  static final java.lang.String _DEFINITION = "duration time\nfloat32 x\nfloat32 y\nfloat32 theta\nfloat32 v\nfloat32 w\n";
  static final boolean _IS_SERVICE = false;
  static final boolean _IS_ACTION = false;
  org.ros.message.Duration getTime();
  void setTime(org.ros.message.Duration value);
  float getX();
  void setX(float value);
  float getY();
  void setY(float value);
  float getTheta();
  void setTheta(float value);
  float getV();
  void setV(float value);
  float getW();
  void setW(float value);
}
