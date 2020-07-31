/*************************************************************************
 * Author:         Salesforce Admin
 * Company:        Transport for NSW
 * Description:    Task Trigger handler logic for Task object.
 *
 * Test Class:    TaskTriggerHandlerTest
 * History
 * <Date>      <Authors Name>      <Brief Description of Change>
 * 25/07/2018  Abhi Indulkar       Created from framework
 *************************************************************************/

public with sharing class TaskTriggerHandler extends TriggerHandler {
    @TestVisible
    private static String DRIVES_TASK_TYPE = 'DRIVES';
    //Handle before insert
    protected override void beforeInsert()
    {
        List<Task> lTasks = (List<Task>) Trigger.new;
        Map<Id, Task> mTaskByCaseId = new Map<Id, Task> ();

        //Determine tasks linked to cases
        for (Task t : lTasks) {
            if (t.WhatId != null && ((String) t.WhatId).startsWith('500') && t.Type == DRIVES_TASK_TYPE) {
                mTaskByCaseId.put(t.WhatId, t);
            }
        }

        if (!mTaskByCaseId.isEmpty()) {
            //Prepopulate Short description of the case on task
            for (Case c :[SELECT Description FROM Case WHERE Id IN :mTaskByCaseId.keySet()]) {
                //update case description on Task
                //Task record will be updated as part of trigger context
                if (String.isNotBlank(c.Description)) {
                    if (String.isBlank(mTaskByCaseId.get(c.Id).Description)) {
                        mTaskByCaseId.get(c.Id).Description = 'Case description:\n' + c.Description;
                    } else {
                        mTaskByCaseId.get(c.Id).Description = mTaskByCaseId.get(c.Id).Description + '\n\nCase description:\n' + c.Description;
                    }
                }

            }
        }
        System.debug(Trigger.new);
    }

    //Handle after insert
    protected override void afterInsert()
    {
        //Merged existing code
        CaseStatusUpdater.changeCaseStatus(Trigger.New);
    }
}

/*********************************************
 * Handler class to trigger execution on Task
 */
/*
  public class TaskTriggerHandler {
 
  public static void afterInsert(List<Task> taskList){
  system.debug('In After Insert method');
  CaseStatusUpdater.changeCaseStatus(taskList);
  }
  }
*/