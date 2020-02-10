classdef CustomMsgConsts
  %CustomMsgConsts This class stores all message types
  %   The message types are constant properties, which in turn resolve
  %   to the strings of the actual types.
  
  %   Copyright 2014-2018 The MathWorks, Inc.
  
  properties (Constant)
    pips_trajectory_msgs_trajectory_point = 'pips_trajectory_msgs/trajectory_point'
    pips_trajectory_msgs_trajectory_points = 'pips_trajectory_msgs/trajectory_points'
  end
  
  methods (Static, Hidden)
    function messageList = getMessageList
      %getMessageList Generate a cell array with all message types.
      %   The list will be sorted alphabetically.
      
      persistent msgList
      if isempty(msgList)
        msgList = cell(2, 1);
        msgList{1} = 'pips_trajectory_msgs/trajectory_point';
        msgList{2} = 'pips_trajectory_msgs/trajectory_points';
      end
      
      messageList = msgList;
    end
    
    function serviceList = getServiceList
      %getServiceList Generate a cell array with all service types.
      %   The list will be sorted alphabetically.
      
      persistent svcList
      if isempty(svcList)
        svcList = cell(0, 1);
      end
      
      % The message list was already sorted, so don't need to sort
      % again.
      serviceList = svcList;
    end
    
    function actionList = getActionList
      %getActionList Generate a cell array with all action types.
      %   The list will be sorted alphabetically.
      
      persistent actList
      if isempty(actList)
        actList = cell(0, 1);
      end
      
      % The message list was already sorted, so don't need to sort
      % again.
      actionList = actList;
    end
  end
end
