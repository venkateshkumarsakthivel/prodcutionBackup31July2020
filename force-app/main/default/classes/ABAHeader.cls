/**
 * @name ABAHeader.cls
 * @description this class is responsible to hold properties required to generate ABA file header, also this will take care of
 * generating header line using specification from ABA document as this will be fixedWidth format specification. specification of
 * each of the property is mentioned as inline comment against declaration and initialization statements.
 */  
public with sharing class ABAHeader {
    public String recordType { get; private set; } { this.recordType = '0'; } /* length: 1 */
    public String blank17 { get; private set; } { this.blank17 = ''; this.blank17 = this.blank17.leftPad(17); } /* length: 17 */
    public String sequenceNumber { get; set; } { this.sequenceNumber = '01'; } /* length: 2 */
    public String financialInstitution { get; set; } /* length: 3 */
    public String blank7 { get; private set; } { this.blank7 = ''; this.blank7 = this.blank7.leftPad(7); } /* length: 7 */
    public String nameOfUserSupplyingFile { get; set; } /* length: 26 */
    public String identificationOfUserSupplyingFile { get; set; } /* length: 6, must be user identification number allocated by APCA.  right justified ZERO filled */
    public String description { get; set; } /* length: 12 */
    public String transactionReleaseDate { get; set; } { this.transactionReleaseDate = DateTime.now().format('ddMMyy'); } /* length: 6, format: DDMMYY */
    public String blank40 { get; private set; } { this.blank40 = ''; this.blank40 = this.blank40.leftPad(40); } /* length: 40 */
    
    
    /**
     * constructor
     */
    public ABAHeader(String psequenceNumber)  {
        //get from Custom Metadata and populate required header attributes here and finally call generate method
        
        WIBS_Configuration__mdt abaConstantsMeta = [SELECT Label, financialInstitution__c, nameOfUserSupplyingFile__c, identificationOfUserSupplyingFile__c, description__c FROM WIBS_Configuration__mdt WHERE DeveloperName = 'ABA_Constants'];
        this.sequenceNumber = String.valueOf(GlobalConstants.ABA_HEADER_REEL_SEQUENCE_NUMBER);
        this.financialInstitution = abaConstantsMeta.financialInstitution__c;
        this.nameOfUserSupplyingFile = abaConstantsMeta.nameOfUserSupplyingFile__c;
        this.identificationOfUserSupplyingFile = abaConstantsMeta.identificationOfUserSupplyingFile__c;
        this.description = abaConstantsMeta.description__c;
    }
    
    override public String toString()  {
        String header = '';
        header += this.recordType + this.blank17;
        header += this.sequenceNumber.leftPad(2, '0');
        header += this.financialInstitution + this.blank7;
        header += this.nameOfUserSupplyingFile.rightPad(26);
        header += this.identificationOfUserSupplyingFile.leftPad(6, '0');
        header += this.description.rightPad(12) + this.transactionReleaseDate + this.blank40;
        
        header += '\r\n';
        
        return header;
    }
}