public without sharing class ContactRetriever {
    
    //retrieve contact details by accepting contact Id
    public static String retrieve(String contactId){
        String retVal;
        List<Contact> contacts = [select id,firstName,lastName,email,accountId from contact where id =: contactId];
        if(!contacts.isEmpty()){
            retVal = '{"firstName":"'+ contacts[0].FirstName +'", "lastName":"' + contacts[0].LastName + '" , "email":"' + contacts[0].Email +'" , "accountId":"' + contacts[0].AccountId +'"}';
        }
        return retVal;
    }
}