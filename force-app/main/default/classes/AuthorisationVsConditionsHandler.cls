public without sharing class AuthorisationVsConditionsHandler {

	private static final Map<String, String> authVsConditionType;
	private static String authorisationType;

	static {

		authVsConditionType = new Map<String, String> ();
		authVsConditionType.put(GlobalConstants.AUTHORISATION_TYPE_TSP,
		                        GlobalConstants.TAXI_SERVICE_PROVIDER);
		authVsConditionType.put(GlobalConstants.AUTHORISATION_TYPE_BSP,
		                        GlobalConstants.BOOKING_SERVICE_PROVIDER);
		authVsConditionType.put(GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE,
		                        GlobalConstants.TAXI_LICENCE_PROVIDER);
	}


	/*
	  Validate if authorisation is granted or not and 
	  accordingly return true or false.
	 */
	@AuraEnabled
	public static Boolean validToAddConditions(Id authRecordId) {
		//modified for : P2PSUPPORT-136
		//Level 3 users should be able to add conditions at any stage of the application
		Profile userProfile = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()];

		if (userProfile.Name == GlobalConstants.P2P_OPERATIONS_LEVEL_3) {
			return true;
		}

		//retrieve authorisation details
		List<Authorisation__c> authorisation = [SELECT Id, Authorisation_Type__c
		                                        FROM Authorisation__c
		                                        WHERE Id = :authRecordId
		                                        AND(Status__c = :GlobalConstants.AUTHORISATION_STATUS_NEW
		                                            OR Status__c = :GlobalConstants.AUTHORISATION_STATUS_DRAFT
		                                            OR Status__c = :GlobalConstants.CASE_SUB_STATUS_DECISION_PENDING)];

		if (authorisation.size() > 0)
		return true;

		return false;
	}


	@AuraEnabled
	public static List<Condition__c> getConditions(Id authRecordId) {
		Map<String, Condition__c> masterVsConditions = new Map<String, Condition__c> ();

		//retrieve authorisation details
		List<Authorisation__c> authorisation = [SELECT Id, Authorisation_Type__c
		                                        FROM Authorisation__c
		                                        WHERE Id = :authRecordId];
		if (authorisation.isEmpty()) {
			throw new InvalidDataException('Authorisation details not available.');
		}

		for (Master_Condition__c master :[SELECT Id, Condition_Details__c, Type__c
		     FROM Master_Condition__c
		     WHERE Status__c = :GlobalConstants.MASTER_CONDITION_ACTIVE
		     AND Type__c = :authVsConditionType.get(authorisation[0].Authorisation_Type__c)]) {

			Condition__c condition = new Condition__c();
			condition.Condition_Details__c = master.Condition_Details__c;
			condition.Authority__c = authRecordId;
			condition.Master_Condition__c = master.Id;
			masterVsConditions.put(master.Id, condition);
		}
		Integer manualConditionCount = 1;
		for (Condition__c condition :[SELECT Id, Condition_Details__c, Authority__c,
		     Internal_Notes__c, Master_Condition__c, Authority__r.Authorisation_Type__c
		     FROM Condition__c
		     WHERE Authority__c = :authRecordId]) {
			if (condition.Master_Condition__c != null) {
				masterVsConditions.put(condition.Master_Condition__c, condition);
			} else {
				masterVsConditions.put(String.valueOf(manualConditionCount), condition);
				manualConditionCount++;
			}

		}

		//add record for one manual entry for condtion
		masterVsConditions.put(null, new Condition__c(Authority__c = authRecordId,
		                                              Condition_Details__c = '', Internal_Notes__c = ''));
		return masterVsConditions.values();
	}

	@AuraEnabled
	public static void attachConditions(String unSelectedConditions, String selectedConditions, String authRecordId) {

		System.debug('unSelectedConditions ' + unSelectedConditions);
		System.debug('selectedConditions ' + selectedConditions);

		//retrieve authorisation details
		List<Authorisation__c> authorisation = [SELECT Id, Authorisation_Type__c
		                                        FROM Authorisation__c
		                                        WHERE Id = :authRecordId];

		//authorisationType = authorisation[0].Authorisation_Type__c;
		authorisationType = authVsConditionType.get(authorisation[0].Authorisation_Type__c);

		List<Condition__c> selectedConditionsToInsert = (List<Condition__c>) JSON.deserialize(selectedConditions, List<Condition__c>.class);
		List<Condition__c> unselectedConditionsToDelete = (List<Condition__c>) JSON.deserialize(unSelectedConditions, List<Condition__c>.class);
		List<Master_Condition__c> masterConditionsToInsert = new List<Master_Condition__c> ();

		/*
		  for(Condition__c tempCon : selectedConditionsToInsert) {
		 
		  if(tempCon.Master_Condition__c == NULL) {
		 
		  Master_Condition__c tempNewMC = new Master_Condition__c();
		  tempNewMC.Condition_Details__c = tempCon.Condition_Details__c;
		  tempNewMC.Type__c = authorisationType;
		  tempNewMC.Status__c = GlobalConstants.MASTER_CONDITION_ACTIVE;                
		  }
		  }*/

		if (selectedConditionsToInsert.size() > 0)
		upsert selectedConditionsToInsert;

		if (unselectedConditionsToDelete.size() > 0)
		delete unselectedConditionsToDelete;

	}

	public class InvalidDataException extends Exception { }
}