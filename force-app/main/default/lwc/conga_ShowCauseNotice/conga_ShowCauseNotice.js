import { LightningElement, track } from 'lwc';

export default class Conga_ShowCauseNotice extends LightningElement {
    @track showValidation = false;
    connectedCallback() {
        window.open('/apex/APXTConga4__Conga_Composer?SolMgr=1&serverUrl={!API.Partner_Server_URL_370}&Id={!Notice_Record__c.Id}&TemplateId=a0C1e000000Darl&CongaEmailTemplateId=a031e0000005tb8&AC0=1&AC1=Follow+up+on+Show+Cause+Notice&AC3={!Notice_Record__c.Number_of_Days__c}&EmailToId={!Notice_Record__c.Served_toId__c}&EmailCC={!Notice_Record__c.Issued_to_Email__c}&DS7Preview=1&DefaultPDF=1&DS7=2&EmailSubject=Failure+to+Pay+PSL+Notice&UF0=1&MFTS0=isCongaEmailNoticeSent__c&MFTSValue0=True&MFTS1=Status__c&MFTSValue1=Sent')
    }
}