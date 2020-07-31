@isTest
private class P2PRMSClientTest
{
	@testSetup static void createTestData(){
		Law_Part_Code__c code=new Law_Part_Code__c();
		code.Name='Test123';
		code.Law_Part_Description__c='Test Data';
		code.Law_Part_Commencement_Date__c=System.Today();
		code.Legislation__c='Crimes Act 1900';
		code.Section_Clause__c='530(1A)';
		code.Status__C='Approved';
		insert code;

		Case parentCase=new Case();
		parentCase.Subject='Overturn charge for licence';
		parentCase.Status='New';
		parentCase.Sub_Status__c='Draft';
		parentCase.Charge_Code_Identifier__c='123456789';
		insert parentCase;

		Case childCase=new Case();
		childCase.Subject='Criminal Offence case for charge code 123456789 : offence code 671478478';
		childCase.ParentId=parentCase.id;
		
		childCase.Offence_Code__c='671478478';
		childCase.Law_Part_Code__c=code.id;
		
		childCase.Status='Lodged';
		//childCase.Sub_Status__c='Assessment Pending';

		childCase.Sub_Status__c='Assessment In Progress';
		insert childCase;


	}

	//Success Test
	@isTest
	static void overturnChargeSuccessTest1()
	{
		Case caseParam = [SELECT CaseNumber, ParentId, Australian_Driver_Licence_Number_Formula__c, Charge_Code_Identifier_Formula__c,
                              Offence_Code__c, Law_Part_Code__r.Name ,Decision__c,Law_Part_Code_Name__c
                              FROM Case 
                              WHERE Subject='Criminal Offence case for charge code 123456789 : offence code 671478478' limit 1];
		P2PRMSClient client=new P2PRMSClient();
		P2PRMSOvtResponseParserVisitor visitor=new P2PRMSOvtResponseParserVisitor();
		Test.startTest();
		P2PRMSOvtMockImplementation.reandomCode1=50;
		try{
		client.call(P2PRMSClient.RMS_REQUEST_TYPE.OVERTURN_CRIMINAL_OFFENCE,visitor, caseParam);
		visitor.updateResponses(); 
		}
		catch(Exception ex){}
		Test.StopTest();
		case updatedCase=[select id,Status,Sub_Status__c,RMS_Response__c from case where id=:caseParam.Id];
		System.assert(updatedCase.Status == 'Closed'  , 'Error occurred in processing ovt criminal offence response.');
		System.assert(updatedCase.Sub_Status__c == 'Approved'  , 'Error occurred in processing ovt criminal offence response.');
		System.assertNotEquals(updatedCase.RMS_Response__c, null);
	}

	//Error test
	@isTest
	static void overturnChargeErrorTest()
	{
		Case caseParam = [SELECT CaseNumber, ParentId, Australian_Driver_Licence_Number_Formula__c, Charge_Code_Identifier_Formula__c,
                              Offence_Code__c, Law_Part_Code__r.Name ,Decision__c,Law_Part_Code_Name__c
                              FROM Case 
                              WHERE Subject='Criminal Offence case for charge code 123456789 : offence code 671478478' limit 1];
        P2PRMSClient client=new P2PRMSClient();
		P2PRMSOvtResponseParserVisitor visitor=new P2PRMSOvtResponseParserVisitor();
		Test.startTest();
		P2PRMSOvtMockImplementation.reandomCode2=50;
		try{
		client.call(P2PRMSClient.RMS_REQUEST_TYPE.OVERTURN_CRIMINAL_OFFENCE,visitor, caseParam);
		visitor.updateResponses(); 
		}
		catch(Exception ex){}
		Test.StopTest();
		case updatedCase=[select id,Status,Sub_Status__c,RMS_Response__c from case where id=:caseParam.Id];
		System.assert(updatedCase.Status == 'Lodged' , 'Assert Failed');
		System.assert(updatedCase.Sub_Status__c == 'Assessment Pending', 'Assert Failed');
		System.assertNotEquals(updatedCase.RMS_Response__c, null);
	}

	//Response parsing Error Test
	@isTest
	static void overturnChargeResponseParseErrorTest()
	{
		Case caseParam = [SELECT CaseNumber, ParentId, Australian_Driver_Licence_Number_Formula__c, Charge_Code_Identifier_Formula__c,
                              Offence_Code__c, Law_Part_Code__r.Name ,Decision__c,Law_Part_Code_Name__c
                              FROM Case 
                              WHERE Subject='Criminal Offence case for charge code 123456789 : offence code 671478478' limit 1];
        P2PRMSClient client=new P2PRMSClient();
		P2PRMSOvtResponseParserVisitor visitor=new P2PRMSOvtResponseParserVisitor();
		Test.startTest();
		P2PRMSOvtMockImplementation.reandomCode2=51;
		try{
		client.call(P2PRMSClient.RMS_REQUEST_TYPE.OVERTURN_CRIMINAL_OFFENCE,visitor, caseParam);
		visitor.updateResponses(); 
		}
		catch(Exception ex){}
		Test.StopTest();
		case updatedCase=[select id,Status,Sub_Status__c from case where id=:caseParam.Id];
		System.assert(updatedCase.Status == 'Lodged'  , 'Assert Failed');
		System.assert(updatedCase.Sub_Status__c == 'Assessment Pending' , 'Assert Failed');
		
	} 

	//RMS ovt callout Exception Test
	@isTest
	static void overturnChargeCallOutErrorTest()
	{
		Case caseParam = [SELECT CaseNumber, ParentId, Australian_Driver_Licence_Number_Formula__c, Charge_Code_Identifier_Formula__c,
                              Offence_Code__c, Law_Part_Code__r.Name ,Decision__c,Law_Part_Code_Name__c
                              FROM Case 
                              WHERE Subject='Criminal Offence case for charge code 123456789 : offence code 671478478' limit 1];
        P2PRMSClient client=new P2PRMSClient();
		P2PRMSOvtResponseParserVisitor visitor=new P2PRMSOvtResponseParserVisitor();
		Test.startTest();
		P2PRMSOvtMockImplementation.reandomCode1=51;
		try{
		client.call(P2PRMSClient.RMS_REQUEST_TYPE.OVERTURN_CRIMINAL_OFFENCE,visitor, caseParam);
		visitor.updateResponses(); 
		}
		catch(Exception ex){
		}
		Test.StopTest();
		case updatedCase=[select id,Status,Sub_Status__c from case where id=:caseParam.Id];
		System.assert(updatedCase.Status == 'Lodged'  , 'Assert Failed');
		System.assert(updatedCase.Sub_Status__c == 'Assessment Pending' , 'Assert Failed');
		
	} 
}