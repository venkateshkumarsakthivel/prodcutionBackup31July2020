/**
 * RMS Response Envelope Test
 */
@isTest
public class RMSResponseEnvelopeTest {
   
    
    private static testmethod void testStructure3(){
        String sample = '{"header":{"messageId":"a0L6D000000XFUwUAO","messageGroupId":"a0K6D000000G1QiUAK","messageRelatedId":"a0K6D000000G1QiUAK",' 
                        + '"createdTimestamp":"2019-06-03T03:16:24","priority":0,"clientId":"P2PREG","clientSystemId":"P2PREG","channelType":"Branch",' 
                        +  '"requestor":[{"requestorType":"ExternalAgent","requestorIdType":"OrganisationCode","requestorId":"TfNSW"},' 
                        + '{"requestorType":"Customer","requestorIdType":"Customer","requestorId":"612982"}],"location":[{"locationId":' 
                        + '"P2P","locationType":"Server"}],"extension":[{"name":"organisationCode","value":"P2PRG1"}]},' 
                        + '"statusMessages":{"overallStatus":"SUCCESS"},"body":{"transactionId":"19-23-000-407-TfNSW",' 
                        + '"vehicleEligibilityStatus":"Y","lastPassedAISInspectionDate":"2018-05-25"}}';
        sample = sample.replaceAll('"class":','"propertyClass":');
        RMSResponseEnvelope res = (RMSResponseEnvelope)JSON.deserializeStrict(sample, RMSResponseEnvelope.class);
        System.assert(res.header != null, 'Header not deserialized');
        System.assert(res.body != null, 'Body not deserialized');
        System.assert(res.getEligibilityStatus() == 'Y', 'Body product licenceassessment eligibilityStatus not deserialized');
    }    
    
    private static testmethod void testStructure4(){
        String sample = '{"header":{"messageId":"ddf252bf-388c-41ac-904b-13a191d1543f ","messageGroupId":"string",' 
        + '"messageRelatedId":"string","createdTimestamp":"2017-11-24T12:31:31 ","priority":0,"clientId":"P2PREG","clientSystemId":"string","channelType":"Branch",' 
        + '"requestor":[{"requestorId":"testuser","requestorType":"Customer","requestorIdType":"Staff"},' 
        + '{"requestorId":"UBER","requestorType":"ExternalAgent","requestorIdType":"OrganisationCode"}],' 
        + '"location":[{"locationId":"12","locationType":"Branch"}]},"statusMessages":{"overallStatus":"ERROR",' 
        + '"message":[{"severity":"ERROR","code":"SYS0000003","description":"Backend internal server error"}]}}';
        sample = sample.replaceAll('"class":','"propertyClass":');
        RMSResponseEnvelope res = (RMSResponseEnvelope)JSON.deserializeStrict(sample, RMSResponseEnvelope.class);
        System.assert(res.header != null, 'Header not deserialized');
        //status message -> overall Status = ERROR
        System.assert(res.getOverallStatus() == 'ERROR', 'Body statusmessage overallstatus not deserialized');
    }    
    
}