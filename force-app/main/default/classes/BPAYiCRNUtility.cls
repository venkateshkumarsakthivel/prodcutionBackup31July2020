/**
 * ICRN Generator utility for BPAY Numbers
 * cf: BPAY ICRN Calculation Information.doc
 */ 
public class BPAYiCRNUtility {
    
    /** aaCRNv format with MOD10V01, MOD10V05 */
    public static String generateICRN(Decimal amount, String crn){
        
        //1st digit
        String a1 = generateMOD10V01(amount);
        
    //2nd digit        
        String a2 = generateMOD10V05(amount);
        
        String aaCRN = a1 + a2 + crn;
        String v = generateMOD10V10 (Decimal.valueOf(aaCRN));
        System.debug('aaCRN + v: '+aaCRN + v);
        return aaCRN + v;
    }
    
    @TestVisible
    private static String generateMOD10V01(Decimal amount){
        
        String amtStr = String.valueOf(amount).replace('.', '');
        Integer amtLen = amtStr.length(), sum = 0, i=amtLen-1;

        Integer multiplicationFactor = 2;
        while(i>=0){
            Integer num = Integer.ValueOf(amtStr.substring(i,i+1));
            //sum += (Math.mod(i--, 2) == 0) ? (num*2/10) + Math.mod(num*2, 10) : num;
            sum+= (multiplicationFactor * num/10) + Math.mod(multiplicationFactor * num, 10);
            multiplicationFactor = multiplicationFactor > 1? 1: 2;
            i--;
        }
        System.debug(LoggingLevel.INFO, 'Sum of digits (MOD10V01): ' + sum);
        
        return String.valueOf(Math.mod(10 - Math.mod(sum, 10), 10));
    }
    
    @TestVisible
    private static String generateMOD10V05(Decimal amount){
        
        String amtStr = String.valueOf(amount).replace('.', '');
        Integer amtLen = amtStr.length(), sum = 0, i=1;
        
        //lpad with zeros to len=12
        Integer padLen = amtLen<12 ? 12-amtLen : 0;
        for(Integer padder=0;padder<padLen;padder++){
            amtStr = '0'+amtStr;
        }
        //should be 12
        amtLen = amtStr.length();
        while(i<=amtLen){
            Integer num = Integer.ValueOf(amtStr.substring(i-1,i));
            sum += num * i++;
        }
        System.debug(LoggingLevel.INFO, 'Sum of numbers: ' + sum);
        return String.valueOf(Math.mod(sum, 10));
    }
    
    @TestVisible
    private static String generateMOD10V10(Decimal aacrn){
        
        Integer[] weights = new Integer[] {1, 3, 7, 1, 3, 7, 1, 3, 7, 1, 3, 7, 1, 3, 7, 1, 3, 7};
        
        String aacrnStr = String.valueOf(aacrn).replace('.', '');
        Integer aacrnLen = aacrnStr.length(), sum = 0, i=0;
        
        //lpad with zeros to len=18
        Integer padLen = aacrnLen<18 ? 18-aacrnLen : 0;
        for(Integer padder=0;padder<padLen;padder++){
            aacrnStr = '0'+aacrnStr;
        }
        //should be 18
        aacrnLen = aacrnStr.length();
        while(i<aacrnLen){
            Integer num = Integer.ValueOf(aacrnStr.substring(i,i+1));
            sum += num * weights[i++];
        }
        Integer mod10 = Math.mod(sum, 10);
        Integer checksum = 0;
        if(mod10 != 0 ) {
            checksum = 10-mod10;
        }
        
        return String.valueOf(checksum);
    }    
    
}