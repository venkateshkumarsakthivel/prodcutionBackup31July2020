/**
 *  Description: Test class for TaskTriggerHandler and CaseStatusUpdater classes
*/
@isTest
public class TaskTriggerHandlerTest {

	@istest
	static void testCaseStatusChange() {
		Id RecordTypeIdCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('Taxi Individual Application').getRecordTypeId();
		Case testcase = new Case(Service_Type__c = 'Taxi', Status = GlobalConstants.LODGED_CASE_STATUS,
		                         Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED, Type = GlobalConstants.TAXI_INDIVIDUAL_APPLICATION,
		                         recordtypeId = RecordTypeIdCase);
		insert testcase;

		Task tsk = new task(Subject = 'Email: Notice of Tender Bid – Expired', WhatId = testcase.Id);
		insert tsk;

		Case case1 = [select Id, Status From Case Where Id = :testcase.Id];
		system.assertEquals('Not Continued', case1.Status);
	}

	@istest
	static void testCreationOfDrivesTask() {
		//Create Case
		Map<String, Object> caseValues = new Map<String, Object> ();
		caseValues.put('Status', GlobalConstants.LODGED_CASE_STATUS);
		caseValues.put('Description', 'Case summary');

		Set<String> ignoreFieldNames = new Set<String> ();
		ignoreFieldNames.add('Name');
		ignoreFieldNames.add('BusinessHoursId');

		Case testCase = (Case) TestDataFactory.createSObject('Case', caseValues, ignoreFieldNames);
		insert testCase;

		Map<String, Object> taskValues = new Map<String, Object> ();
		taskValues.put('Type', TaskTriggerHandler.DRIVES_TASK_TYPE);
		taskValues.put('Description', '');
		taskValues.put('WhatId', testCase.Id);

		ignoreFieldNames = new Set<String> ();
		ignoreFieldNames.add('Name');

		Task testTask = (Task) TestDataFactory.createSObject('Task', taskValues, ignoreFieldNames);
		insert testTask;

		System.assertEquals('Case description:\nCase summary' , [SELECT Description FROM Task WHERE Id = :testTask.Id].Description);
		
	}
}