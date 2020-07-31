/**
 * Test class for BPAY ICRN Utility
 */
@isTest
private class BPAYiCRNUtilityTest {
    
    private static testmethod void testGenerateMOD10V01(){

        String checksum = BPAYiCRNUtility.generateMOD10V01(12783.61);
        System.assert(checksum == '9', 'Invalid Checksum - Expected 9 received:' + checksum);
        System.assert(BPAYiCRNUtility.generateMOD10V01(112233) == '2', 'Invalid checksum, Expected 2');
        System.assert(BPAYiCRNUtility.generateMOD10V01(1) == '8', 'Invalid checksum, expected 8');
    }
    
    private static testmethod void testGenerateMOD10V05(){
       String checksum = BPAYiCRNUtility.generateMOD10V05(12783.61);
       System.assert(BPAYiCRNUtility.generateMOD10V05(12783.61) == '6', 'Invalid checksum, Expected 6');
    }        

    private static testmethod void testGenerateMOD10V10(){
        System.assert(BPAYiCRNUtility.generateMOD10V10(96153246) == '8', 'Invalid checksum, Expected 8');
    }        
    
    private static testmethod void testGenerateICRN(){

        String crn = '153246';
        Decimal amount = 12783.61;
        System.assert(BPAYiCRNUtility.generateICRN(amount, crn) == '961532468');        
    }    
    
}