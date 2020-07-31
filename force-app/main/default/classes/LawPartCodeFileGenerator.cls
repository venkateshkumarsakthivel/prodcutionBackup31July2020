/**
 * @Description: Abstract helper class to generate csv file for law part code to be consumed by downstream systems
 * @Author: Arxxus Technology Partners Pty Ltd
 * @Date: 21/08/2018
 */
public abstract with sharing class LawPartCodeFileGenerator implements ICsvFileGenerator{

    public enum ACTION {Add, Remove, Change}
    private static final String DATA_SEPARATOR = ',';
    private static final String DEFAULT_FILENAME = 'LPC_Default_File';
    
    /* filename to be used for generated csv file */
    protected String filename;
    
    public LawPartCodeFileGenerator(){
        setFileName(DEFAULT_FILENAME);
    }
    
    /* Set name of generated csv file */
    public void setFileName(String filename){
        this.filename = filename + '_' + System.now().format('ddMMyyyy') + '.csv';
    }
    
    
    /** Abstract method to retrieve qualified law part codes. 
     *  Each child class extending LawPartCodeFileGenerator should provide implementation of this method 
     */
    public abstract List<LawPartCode> retrieveQualifiedLPC();  
    
    /* Helper method to generate csv file based on law part codes.
     * Returns null if there are no data rows to be included in the csv file 
     */
    public Attachment generateCsvFile(){
        List<LawPartCode> lpcPartCodes = retrieveQualifiedLPC();
        if(lpcPartCodes.isEmpty()){
            generateLog('Downstream CSV file generation(' 
                            + this.filename + '): No new data to export.');
            return null;
        }
        Application_Log__c log = generateLog('Downstream CSV file generation(' 
                                                + this.filename + '): Generating export of ' 
                                                + lpcPartCodes.size() + ' rows.');
            
        //common csv generation logic
        String csvData = '';
        String fileHeader = generateHeader();
        csvData += fileHeader;
        
        for(LawPartCode code : lpcPartCodes){
            String dataRow = generateDataRow(code);            
            csvData += dataRow;
        }
        
        //create csv file attachment and link it with application log.
        return createAttachment(csvData, log.Id);
    }
    
    /* wrapper class for law part codes */
    public class LawPartCode {
        private String code;
        private String legislation;
        private String sectionOrClause;
        private String lawPartDescription;
        private String specialConditions;
        private ACTION actionValue;
        
        public LawPartCode(String code, String legislation, String section, 
                                    String description, String conditions, ACTION action){
            this.code = code;
            this.legislation = legislation;
            this.sectionOrClause = section;
            this.lawPartDescription = description;
            this.specialConditions = conditions;
            this.actionValue = action;
        }
        
        public LawPartCode(String code, String legislation, String section, 
                                    String description, String conditions){
            this(code, legislation, section, description, conditions, ACTION.ADD);
        } 
    }
    
    /* Helper method to generate header row for csv file */
    private String generateHeader(){
        String headerRow = formatData('Law Part Code') + DATA_SEPARATOR;
        headerRow += formatData('Legislation') + DATA_SEPARATOR;
        headerRow += formatData('Section/Clause') + DATA_SEPARATOR;
        headerRow += formatData('Law Part Description') + DATA_SEPARATOR;
        headerRow += formatData('Special Conditions') + DATA_SEPARATOR;
        headerRow += formatData('Action');
        return headerRow;
    }
    
    /* Helper method to generate data row for each law part code to be included in the csv file */
    private String generateDataRow(LawPartCode code){
        String dataRow = '\n';
        dataRow += formatData(code.code) + DATA_SEPARATOR;
        dataRow += formatData(code.legislation) + DATA_SEPARATOR;
        dataRow += formatData(code.sectionOrClause) + DATA_SEPARATOR;
        dataRow += formatData(code.lawPartDescription) + DATA_SEPARATOR;
        dataRow += formatData(code.specialConditions) + DATA_SEPARATOR;
        dataRow += formatData(code.actionValue.name());
        return dataRow;
    }
    
    
    /* Helper method to capture the csv generation process in application log */
    private Application_Log__c generateLog(String message){
        Application_Log__c log = new Application_Log__c();
        log.Debug_Level__c = GlobalConstants.INFO;
        log.Message__c = message;
        log.Source__c = 'LawPartCodeFileGenerator';
        log.Source_Function__c = 'generateCsv';        
        insert log;
        
        return log;
    }
    
    private Attachment createAttachment(String csvData, Id parentId){
        Attachment attach = new Attachment();
        attach.Body = Blob.valueOf(csvData);
        attach.Name = filename;
        attach.ContentType = 'text/csv';
        attach.ParentId = parentId;        
        insert attach;
        
        return attach;
    }
    
    private String formatData(String data){
        if (data == null) data = '';
        //return String.isBlank(data)? '\"\"'  : '\"' + data + '\"';
        return data.escapeCsv();
    }
}