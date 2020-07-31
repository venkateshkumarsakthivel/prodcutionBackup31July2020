/**
 * Copyright 2014 Arxxus Technology Partners Pty Ltd. All rights reserved.
 * Arxxus PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
 * 
 * Arxxus Utilities Framework
 * @author raghu
 */
 
 
 /**
  * CSV Parser - Only works with files that do not contain newlines in fields
  */
global class ATP_CSVParser implements Iterator<List<String>> {
    
    /** the header Row Raw Data */
    private String rawHeaderRow;
    
    private List<String> headerRow;
    
    /** the parsed input file as list of Strings */
    private  List<String> lines;
    
    /** handle to current iteration index */
    private Integer iterationIx = 1;
    
    /** the raw file as String */
    public String rawFileData {get;set;}
    
    /** parsed input file as list of fields */
    private final List<List<String>> allFields;
    
    /** field Separator */
    private final String FIELDSEP;
    
    /** row Separator */
    private final String ROWSEP;

    private static final String COMMASEP = ',';

    /**
     * return the header line
     */
    public String getRawHeaderRow() {
        return this.rawHeaderRow;
    }
    
    /**
     * return the raw header row
     */
    public List<String> getHeaderRow() {
        return this.headerRow;
    }
    
    
    /**
     * Create an instance of the Parser with passed Blob
     */
    public ATP_CSVParser(Blob contentFile, boolean hasHeaderRow, String fieldSep) { 
        this(contentFile, hasHeaderRow, fieldSep, '\r\n');
    }
    
    /**
     * Create an instance of the Parser with passed Blob
     */
    public ATP_CSVParser(Blob contentFile, boolean hasHeaderRow, String fieldSep, String rowSep) { 
        this(contentFile.toString(), hasHeaderRow, fieldSep, rowSep);
    }

    /**
    * Default header row exists, comma field sep
    */    
    public ATP_CSVParser(String contentFile){
        this.FIELDSEP = COMMASEP;
        this.ROWSEP   = '\r\n';
        this.allFields = parseCSV(contentFile, true);        
    }

    /**
    * Default comma field sep
    */    
    public ATP_CSVParser(String contentFile, boolean hasHeaderRow){
        this.FIELDSEP = COMMASEP;
        this.ROWSEP   = '\r\n';
        this.allFields = parseCSV(contentFile, hasHeaderRow);        
    }

    /**
     * Create an instance of the Parser with passed String
     */
    public ATP_CSVParser(String contentFile, boolean hasHeaderRow, String fieldSep){
        this.FIELDSEP = fieldSep;
        this.ROWSEP   = '\r\n';
        this.allFields = parseCSV(contentFile, hasHeaderRow);        
    }

    /**
     * Create an instance of the Parser with passed String
     */
    public ATP_CSVParser(String contentFile, boolean hasHeaderRow, String fieldSep, String rowSep){
        this.FIELDSEP = fieldSep;
        this.ROWSEP   = rowSep;
        this.allFields = parseCSV(contentFile, hasHeaderRow);        
    }
    
    /**
     * adapted from http://wiki.developerforce.com/page/Code_Samples#Parse_a_CSV_with_APEX
     */
    private List<List<String>> parseCSV(String contents, Boolean hasHeaderRow ) {
        
        List<List<String>> allFields = new List<List<String>>();
        system.debug('****contents*******' + contents);
        // replace instances where a double quote begins a field containing a comma
        // in this case you get a double quote followed by a doubled double quote
        // do this for beginning and end of a field
        contents = contents.replaceAll(this.FIELDSEP + '"""',this.FIELDSEP + '"DBLQT')
                           .replaceall('"""' + this.fieldSep,'DBLQT"' + this.fieldSep);

        // now replace all remaining double quotes - we do this so that we can reconstruct
        // fields with commas inside assuming they begin and end with a double quote
        contents = contents.replaceAll('""','DBLQT');
    
        // we are not attempting to handle fields with a newline inside of them
        // so, split on newline to get the spreadsheet rows
        this.lines = new List<String>();
        try {
            
            system.debug('****contents*******' + contents);
            system.debug('****this.ROWSEP*******' + this.ROWSEP);
            
            this.lines = contents.split(this.ROWSEP);

            if(hasHeaderRow) {
            
                this.rawHeaderRow = lines.get(0);
                //revert to raw Data format
                this.rawHeaderRow.replaceAll('DBLQT','"');
            }
        
            Integer num = 0;
            
            for(String line : this.lines) {
            
                // check for blank CSV lines (only fieldseparators)
                //if (line.replaceAll(this.FIELDSEP,'').trim().length() == 0) break;
                
                List<String> fields = line.split(this.FIELDSEP);  
                List<String> cleanFields = new List<String>();
                String compositeField;
                Boolean makeCompositeField = false;
                for(String field : fields) {
                    //System.debug('field = ' + field);
                    if (field.startsWith('"') && field.endsWith('"')) {
                        cleanFields.add(field.replaceAll('DBLQT','"'));
                    } else if (field.startsWith('"')) {
                        makeCompositeField = true;
                        compositeField = field;
                    } else if (field.endsWith('"')) {
                        compositeField += this.FIELDSEP + field;
                        cleanFields.add(compositeField.replaceAll('DBLQT','"'));
                        makeCompositeField = false;
                    } else if (makeCompositeField) {
                        compositeField +=  this.FIELDSEP + field;
                    } else {
                        cleanFields.add(field.replaceAll('DBLQT','"'));
                    }
                }
                
                allFields.add(cleanFields);
                //System.debug('Added Row = ' + cleanFields);
    
            }
            if(hasHeaderRow) {
                this.headerRow = allFields.remove(0);
                //System.debug('Removed Header Row from fields = ' + this.headerRow);
            }
            System.debug('All Fields = ' + allFields);
    
            return allFields; 
            
        }  
        catch(System.ListException e) {
            
            System.debug('Limits exceeded?' + e.getMessage());
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'ATP_CSVParser', 'parseCSV', e.getMessage(), e);
            return NULL;
        }    
    }
    
    //iterator methods
    /**
     * Check if the fields data list has remaining rows
     */
    global Boolean hasNext(){ 
      return allFields.size() > 0;
    }    
    
    /**
     * return the next available row of fields
     */
    global List<String> next(){
        iterationIx++;
        return allFields.remove(0);
    }
    
    /**
     * return the raw row data corresponding to the
     * current iteration handle -1 
     * This is to correspond to the same data as fetched in the preceding next call
     * Note that to use this correctly, the calls must be in the following order:
     * List<String> data = iterator.next();
     * String rawData = iterator.rawRowAtIteratorIndex();
     */
    public String rawRowAtIteratorIndex() {
        String line = lines.get(iterationIx-1);
        line.replaceAll('DBLQT', '"');
        return line;
    }
   
}