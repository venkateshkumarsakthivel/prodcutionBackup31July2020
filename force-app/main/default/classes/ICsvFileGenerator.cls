/**
 * @Description: Interface for csv file generation to be consumed by downstream systems
 * @Author: Arxxus Technology Partners Pty Ltd
 * @Date: 21/08/2018
 */
public interface ICsvFileGenerator{

    Attachment generateCsvFile();
    void setFileName(String filename);
}