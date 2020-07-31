/*------------------------------------------------------------

Description:   A global constants class for the project

------------------------------------------------------------*/
global with sharing class GlobalConstants {
    
    public static final String DEBUG ='Debug';//logging level
    public static final String ERROR ='Error';//logging level
    public static final String INFO ='Info';//logging level
    public static final String WARNING ='Warning';//logging level 
    
    //case record types
    public static final String CASE_RECORDTYPE_CORPORATION = 'Corporation Application';
    public static final String CASE_RECORDTYPE_INDIVIDUAL = 'Individual Application';
    public static final String CASE_RECORDTYPE_HELPREQUEST = 'Help Request';
    public static final String CASE_RECORDTYPE_PARTNERSHIP = 'Partnership Application';
    public static final String CASE_RECORDTYPE_REVIEWABLE_DECISIONS = 'Reviewable Decisions';
    public static final String CASE_RECORDTYPE_REVIEWABLE_DECISIONS_DEVNAME = 'Reviewable_Decisions';
    public static final String CASE_RECORDTYPE_NOTIFIABLE_OCCURRENCE = 'Notifiable Occurrence';
    public static final String CASE_RECORDTYPE_FAILURE_REGISTER_LEVY = 'Failure to Register for Levy';
    public static final String CASE_RECORDTYPE_UNAUTHORISED_SERVICE_PROVIDER = 'Unauthorised Service Provider';
    
    //Authorisation Record types
    public static final String AUTHORISATION_RECORDTYPE_LOCKED = 'Locked Authorisations';
    public static final String AUTHORISATION_RECORDTYPE_UNLOCKED = 'Granted Authorisation';
    public static final String AUTHORISATION_RECORDTYPE_DEFAULT = 'Default';
    
    //account record types dev names
    public static final String ACCOUNT_RECORDTYPE_DEV_NAME_CORPORATION = 'Company';
    public static final String ACCOUNT_RECORDTYPE_DEV_NAME_INDIVIDUAL = 'Individual';
    public static final String ACCOUNT_RECORDTYPE_DEV_NAME_INDIVIDUAL_PARTNERSHIP ='Individual_Partnership';
    public static final String ACCOUNT_RECORDTYPE_DEV_NAME_CORPORATE_PARTNERSHIP ='Corporate_Partnership';
    
    
    //account record types dev names
    public static final String ACCOUNT_RECORDTYPE_NAME_CORPORATION = 'Company';
    public static final String ACCOUNT_RECORDTYPE_NAME_INDIVIDUAL = 'Individual';
    public static final String ACCOUNT_RECORDTYPE_NAME_INDIVIDUAL_PARTNERSHIP ='Individual Partnership';
    public static final String ACCOUNT_RECORDTYPE_NAME_CORPORATE_PARTNERSHIP ='Corporate Partnership';
    
    
    
    //Account Entity Types
    public static final string ACCOUNT_ENTITY_TYPE_INDIVIDUAL_PARTNERSHIP = 'Individual Partnership/Joint Holders';
    public static final string ACCOUNT_ENTITY_TYPE_CORPORATE_PARTNERSHIP = 'Corporate Partnership/Joint Holders';
    public static final string ACCOUNT_ENTITY_TYPE_CORPORATION ='Corporation';
    public static final string ACCOUNT_ENTITY_TYPE_INDIVIDUAL ='Individual';
    
    
    //contact types
    public static final String CONTACT_NOMINATED_DIRECTOR_TYPE = 'Nominated Director/Manager';
    public static final String CONTACT_CLOSE_ASSOCIATE_TYPE = 'Close Associate';
    public static final String CONTACT_CORPORATE_PARTNERSHIP_TYPE = 'Corporate Partner';
    public static final String CONTACT_INDIVIDUAL_PARTNERSHIP_TYPE = 'Individual Partner';
    public static final String INDIVIDUAL_RECORD_TYPE = 'Individual';
    public static final String CORPORATE_RECORD_TYPE = 'Corporate';
    public static final String CONTACT_GENERAL_CONTACT = 'General Contact';
    
    //case statuses
    public static final String ASSESSMENT_INPROGRESS = 'Assessment In Progress';
    
    //case approval statuses
    public static final String CASE_APPROVED = 'Approved';
    
    //case New statuses
    public static final String CASE_NEW = 'New';
    
    //case Draft statuses
    public static final String CASE_DRAFT = 'Draft';
    public static final String CASE_SUB_STATUS_DRAFT = 'Draft';
    public static final String CASE_SUB_STATUS_PROCESSING_PAYMENT = 'Processing Payment';
    
    //authorisation granted statuses
    public static final String GRANTED_UNCONDITIONALLY = 'Granted Unconditionally';
    public static final String GRANTED_CONDITIONALLY = 'Granted with Conditions';
    public static final String TAXI_LICENCE_GRANTED_STATUS = 'Granted';
    
    //authorisation suspended statuses
    public static final String AUTHORISATION_GRANTED = 'Granted';
    public static final String AUTHORISATION_SUSPENDED = 'Suspended';
    
    //superseeded authorisation status
    public static final String SUPERSEEDED_AUTHORISATION_STATUS = 'Superseded';
    //Surrendered authorisation status
    public static final String SURRENDERED_AUTHORISATION_STATUS = 'Surrendered'; 
    
    //service types
    public static final String SERVICE_TYPE_TAXI = 'Taxi';
    public static final String SERVICE_TYPE_BOOKING = 'Booking';
    public static final String SERVICE_TYPE_TAXI_BOOKING = 'Taxi and Booking';
    
    public static final String INTERNATIONAL_ADDR_YES = 'Yes';
    
    //authorisation types
    public static final String AUTHORISATION_TYPE_TSP = 'TSP';
    public static final String AUTHORISATION_TYPE_BSP = 'BSP';
    public static final String AUTHORISATION_TYPE_TAXI_LICENCE = 'Taxi Licence';
    
    //authorisation status
    public static final String AUTHORISATION_STATUS_NEW = 'New';
    public static final String AUTHORISATION_STATUS_DRAFT = 'Draft';
    public static final Set<String> AUTHORISATION_VALID_RETURN_STATUS = new Set<String>{'Granted With Conditions', 'Granted Unconditionally'};
    public static final Set<String> AUTHORISATION_STATUS = new Set<String>{'Granted With Conditions', 'Granted Unconditionally'};
    public static final String AUTHORISATION_STATUS_CANCELLED = 'Cancelled';
    public static final String AUTHORISATION_STATUS_WITHDRAWN = 'Withdrawn';
    public static final String AUTHORISATION_STATUS_REFUSED = 'Refused';
    public static final String AUTHORISATION_STATUS_DISCARDED = 'Discarded';
    public static final String AUTHORISATION_STATUS_PENDING_APPROVAL = 'Pending Approval';
    public static final String AUTHORISATION_STATUS_EXPIRED = 'Expired';
    public static final String AUTHORISATION_STATUS_RETIRED = 'Retired';
    
    //authorisation types
    public static final String CONDITIONAL_AUTHORISATION = 'Conditional';
    public static final String UNCONDITIONAL_AUTHORISATION = 'Unconditional';
    
    //case statuses
    public static final String APPLICATION_STATUS_LODGED = 'Lodged';
    public static final String APPLICATION_STATUS_REFUSED = 'Refused';
    public static final String APPLICATION_STATUS_DRAFT = 'Draft';
    
    //master condition type
    public static final String TAXI_SERVICE_PROVIDER = 'Taxi Service Provider';
    public static final String BOOKING_SERVICE_PROVIDER = 'Booking Service Provider';
    public static final String TAXI_LICENCE_PROVIDER = 'Taxi Licence';
    public static final String TAXI_WAT_LICENCE_PROVIDER = 'WAT Licence';
    
    public static final String TAXI_LICENCE_CONDITION_CATEGORY = 'Taxi';
    
    //master condition status
    public static final String MASTER_CONDITION_ACTIVE = 'Active';
    
    //authorisation surrender reason
    public static final String AUTHORISATION_SURRENDER_REASON = 'Voluntary Surrender';
    
    //PSP user profile name
    public static final String ACCOUNT_MANAGER_USER_PROFILE_NAME = 'Account Manager';
    public static final String TAXI_AGENT_USER_PROFILE_NAME = 'Taxi Agent Users';
    
    //MSC Profile name
    public static final String MSC_PROFILE_NAME = 'DVD User';
    
    //ASP Profile Name
    public static final String ASP_PROFILE_NAME = 'Authorised Service Provider';
    
    //ASP Profile Name
    public static final String ASP_COMMUNITY_PLUS_PROFILE_NAME = 'Customer Community Plus Authorisation User';
    
    //Taxi Licence Prospect Profile Name
    public static final String TAXI_LICENCE_PROSPECT_PROFILE_NAME = 'Taxi Licence Prospect';
    
    //Taxi Licence User Profile Name
    public static final String TAXI_LICENCE_USER_PROFILE_NAME = 'Taxi Licences User';
    
    //PSPuser  profile name
    public static final String PSP_PROFILE_NAME = 'Prospective Service Provider';
    
    //System Administrator profile name
    public static final String ADMIN_PROFILE_NAME = 'System Administrator';
    
    //PSP Profile Name
    public static final String PROSPECTIVE_SERVICE_PROVIDER_USER_PROFILE_NAME = 'Prospective Service Provider';
    
    //authorisation surrender case subject
    public static final String SURRENDER_AUTHORISATION_CASE_SUBJECT = 'Voluntary surrender of existing Authorisation';
    
    //authorisation surrender case subject
    public static final String SURRENDER_LICENCE_CASE_SUBJECT = 'Voluntary surrender of existing Licence';
    
    public static final String NEW_ASP_APPLICATION_CASE_SUBJECT = 'New ASP Application';
    
    //authorisation variation case subject
    public static final String VARIATION_AUTHORISATION_CASE_SUBJECT = 'Variation of existing authorisation';
    
    //authorisation variation case subject
    public static final String VARIATION_AUTHORISATION_TAXI_CASE_SUBJECT = 'Variation of existing licence';
    
    //authorisation cancel case subject
    public static final String TAXI_CANCEL_AUTHORISATION_CASE_SUBJECT = 'Cancellation of existing licence';
    
    //authorisation suspend case subject
    public static final String TAXI_SUSPEND_AUTHORISATION_CASE_SUBJECT = 'Suspension of existing licence';
    
    //authorisation cancel case subject
    public static final String ASP_CANCEL_AUTHORISATION_CASE_SUBJECT = 'Cancellation of existing Authorisation';
    
    //authorisation suspend case subject
    public static final String ASP_SUSPEND_AUTHORISATION_CASE_SUBJECT = 'Suspension of existing Authorisation';
    
    //support request case record type name
    public static final String SUPPORT_REQUEST_CASE_RECORD_TYPE_NAME = 'Support Request';
    
    //service provider administration case record type name
    public static final String SERVICE_PROVIDER_ADMINISTRATION_CASE_RECORD_TYPE_NAME = 'Service Provider Administration';
    
    //case record type for vary/cancel/suspend
    public static final String VARY_CANCEL_SUSPEND_LICENCE_RECORD_TYPE = 'Vary/Suspend/Cancel Licence';
    
    //service provider administration case record type dev name
    public static final String SERVICE_PROVIDER_ADMINISTRATION_CASE_RECORD_TYPE_DEV_NAME = 'Service_Provider_Administration';
    
    //service provider case type
    public static final String SERVICE_PROVIDER_CASE_TYPE = 'Service Provider';
    
    public static final String CASE_SUBTYPE_NEW_APPLICATION = 'New Application';
    public static final String CASE_SUBTYPE_INTERNAL_REVIEW = 'Internal review';
    public static final String CASE_SUBTYPE_RENEW_APPLICATION = 'Renewal Application';
     public static final String CASE_SUBTYPE_NONRENEW_APPLICATION = 'Non Renewal Application';
    //voluntary return case sub type
    public static final String VOLUNTARY_RETURN_CASE_SUB_TYPE = 'Voluntary Surrender';
    
    //Suspend case sub type
    public static final String SUSPEND_CASE_SUB_TYPE = 'Suspend';
    
    //Cancel case sub type
    public static final String CANCEL_CASE_SUB_TYPE = 'Cancel';
    
    //expiry case sub type
    public static final String EXPIRY_CASE_SUB_TYPE = 'Expiry';
    
    //Surrender case sub type
    public static final String SURRENDER_CASE_SUB_TYPE = 'Surrender';
    
    //closed case status
    public static final String CLOSED_CASE_STATUS = 'Closed';
    
    //cancelled case status
    public static final String CANCELLED_CASE_STATUS = 'Cancelled';
    
    //lodged case status
    public static final String LODGED_CASE_STATUS = 'Lodged';
    
    //withdrawn case sub status
    public static final String WITHDRAWN_CASE_SUB_STATUS = 'Lodged';
    
    //approved case sub status
    public static final String APPROVED_CASE_SUB_STATUS = 'Approved';
    
    //declined case sub status
    public static final String DECLINED_CASE_SUB_STATUS = 'Declined';
    
    //addcontact case sub status
    public static final String ADD_CONTACT_CASE_SUB_STATUS = 'Add Contact';
    
    //contact with NSW address
    public static final String CONTACT_WITH_NSW_ADDRESS = 'NSW'; 
    
    //success message
    public static final String SUCCESS_MESSAGE_TO_BE_RETURNED = 'Success';
    
    //case type service provider 
    public static final String CASE_SERVICE_PROVIDER_TYPE = 'Service Provider';   
    
    //case sub type voluntary return
    public static final String CASE_VOLUNTARY_RETURN_SUB_TYPE = 'Voluntary Surrender';  
    
    //authorisation decision reason 
    public static final String AUTHORISATION_DECISION_REASON = 'Voluntary withdraw by applicant';
    
    //authorisation decision reason 
    public static final String TAXI_APP_CANCELLED_DECISION_REASON = 'Discontinued';
    
    //OWD email record name for emails sent via ASP protal
    public static final String INDUSTRY_PORTAL_OWD_EMAIL_NAME = 'Reply To Industry Portal';
    
    //OWD email record name for emails sent via Taxi protal
    public static final String TAXI_PORTAL_OWD_EMAIL_NAME = 'Reply To Taxi Portal';
    
    //Email template developer name for return request email notification
    public static final String AUTH_RETURN_REQUEST_EMAIL_TEMPLATE_DEV_NAME = 'Request_for_return_of_authorisation';
    
    //case sub status Review Pending
    public static final String CASE_STATUS_REVIEW_PENDING = 'Review Pending';
    
    //case sub status Review In Progress
    public static final String CASE_STATUS_REVIEW_IN_PROGRESS = 'Review In Progress';
    
    public static final String CASE_SUB_STATUS_ASSESSMENT_PENDING = 'Assessment Pending';
    public static final String CASE_SUB_STATUS_ASSESSMENT_INPROGRESS = 'Assessment In Progress';
    public static final String CASE_SUB_STATUS_DECISION_PENDING = 'Decision Pending';
    public static final String CASE_SUB_STATUS_DECISION_INPROGRESS = 'Decision In Progress';
    
    //case sub type variation
    public static final String CASE_SUB_TYPE_VARIATION = 'Variation';
    public static final String CASE_SUB_TYPE_MAINTAIN_AUTHORISATION = 'Maintain Authorisation';
    public static final String CASE_SUB_STATUS_GRANTED = 'Granted';
    
    //case sub type variation
    public static final String CASE_SUB_TYPE_TRANSFER_OWNER = 'Transfer - Owner';
    public static final String CASE_SUB_TYPE_TRANSFER_PROPOSED_OWNER = 'Transfer - Proposed Owner';
    
    public static final String CASE_SUBJECT_TRANSFER_OWNER = 'Transfer - Owner';
    public static final String CASE_SUBJECT_TRANSFER_PROPOSED_OWNER = 'Transfer - Proposed Owner';   
    
    //taxi individual application record type name
    public static final String TAXI_INDIVIDUAL_APPLICATION = 'Taxi Individual Application';
    
    //taxi corporation application record type name
    public static final String TAXI_CORPORATION_APPLICATION = 'Taxi Corporation Application';
    
    //taxi joint holder application record type name
    public static final String TAXI_JOINT_HOLDER_APPLICATION = 'Taxi Joint Holder Application';
    
    //taxi transfer application record type name
    public static final String TAXI_TRANSFER_APPLICATION = 'Transfer';
    
    //taxi case type
    public static final String TAXI_CASE_TYPE = 'Taxi';
    
    //taxi application case subject
    public static final String NEW_TAXI_APPLICATION_CASE_SUBJECT = 'Taxi Licence Application'; 
    public static final String WAT_LICENCE_APPLICATION_CASE_SUBJECT = 'WAT Licence Application';
    
    public static final String PENDING_PAYMENT_SUB_STATUS = 'Pending Payment';
    
    public static final String CASE_MAINTAIN_REQUEST_DEACTIVATE_CONTACT = 'Deactivate Contact';
    
    //tender case record type dev name
    public static final String TENDER_CASE_RECORD_TYPE_DEV_NAME = 'Tender';
    
    //tender case record type name
    public static final String TENDER_CASE_RECORD_TYPE_NAME = 'Tender';
    
    public static final String READY_TO_BE_SENT_SUB_STATUS = 'Ready To Be Sent';
    
    //Permission set name Prospect Taxi Community Access
    public static final String PROSPECT_TAXI_COMMUNITY_ACCESS = 'Prospect_Taxi_Community_Access';
    
    
    //Permission set name Taxi Community Access
    public static final String TAXI_COMMUNITY_ACCESS = 'Taxi_Community_Access';
    
    //Permission set name ASP Community Access
    public static final String ASP_COMMUNITY_ACCESS = 'ASP_Community_Access';
    
    //Deactivated Description
    public static final String DEACTIVATION_DESCRIPTION = 'Contact deactivation request';
    
    //Manage Account user access level for SPA
    public static final String MANAGE_ACCOUNT_USER ='Manage Account user';
    
    //DVD User access level for SPA
    public static final String DVD_USER ='DVD User';
    
    //Full access user access level for SPA
    public static final String FULL_ACCESS_USER ='Full Access user';
    
    //Taxi Licence Authorisation Record Type Name
    public static final String TAXI_LICENCE_AUTHORISATION ='Taxi Licence';
    
    //Taxi Licence Authorisation Record Type Dev Name
    public static final String TAXI_LICENCE_AUTHORISATION_DEV_NAME ='Taxi_Licence';
    
    //Authorisation Request Types
    public static final String CANCEL_REQUEST_TYPE = 'Cancel';
    public static final String SUSPEND_REQUEST_TYPE = 'Suspend';
    public static final String UNSUSPEND_REQUEST_TYPE = 'Unsuspend';
    public static final String RENEW_REQUEST_TYPE = 'Renew';
    public static final String VARIATION_REQUEST_TYPE = 'Vary';
    public static final String RETURN_REQUEST_TYPE = 'Return';
    
    //Taxi Administration Case Record Type Name
    public static final String TAXI_ADMINISTRATION_CASE_RECORD_TYPE_NAME = 'Taxi Administration';
    
    //Taxi Administration Case Record Type Dev Name
    public static final String TAXI_ADMINISTRATION_CASE_RECORD_TYPE_DEV_NAME = 'Taxi_Administration';
    
    //Taxi Administration Case Record Type Name
    public static final String TAXI_TRANSFER_CASE_RECORD_TYPE_NAME = 'Transfer';
    
    //case type taxi 
    public static final String CASE_TAXI_TYPE = 'Taxi';
    
    
    //case RecordType taxi 
    public static final String CASE_RECORD_TYPE_DEV_NAME_TAXI= 'Taxi';
    
    //Vary/Suspend/Cancel case record type name
    public static final String CANCEL_SUSPEND_VARY_CASE_RECORD_TYPE_NAME = 'Vary/Suspend/Cancel Licence';   
    
    //Vary/Suspend/Cancel case record type dev name
    public static final String CANCEL_SUSPEND_VARY_CASE_RECORD_TYPE_DEV_NAME = 'Vary_Suspend_Cancel_Licence';   
    
    public static final String ASP_CORPORATION_CASE_RECORD_TYPE_DEV_NAME = 'Corporation_Application';
    public static final String ASP_INDIVIDUAL_CASE_RECORD_TYPE_DEV_NAME = 'Individual_Application';
    public static final String ASP_PARTNERSHIP_CASE_RECORD_TYPE_DEV_NAME = 'Partnership_Application';
    public static final String TAXI_CORPORATION_CASE_RECORD_TYPE_DEV_NAME = 'Taxi_Corporation_Application';
    public static final String TAXI_INDIVIDUAL_CASE_RECORD_TYPE_DEV_NAME = 'Taxi_Individual_Application';
    public static final String TAXI_PARTNERSHIP_CASE_RECORD_TYPE_DEV_NAME = 'Taxi_Joint_Holder_Application';
    
    //Exception message duplicate value
    public static final String  DUPLICATE_VALUE_EXCEPTION = 'DUPLICATE_VALUE';
    
    //Exception Message Invalid Date
    public static final String  INVALID_DATE_EXCEPTION = 'Invalid date';
    
    //Exception Message Invalid Age
    public static final String  INVALID_AGE_EXCEPTION = 'FIELD_CUSTOM_VALIDATION_EXCEPTION';
    
    //Error Message to return - Duplicate value 
    public static final String  DUPLICATE_VALUE_MESSAGE = 'Vehicle Already Exist';
    
    //Error Message to return - Invalid date 
    public static final String  INVALID_DATE_MESSAGE = 'Invalid Date';
    
    //Error Message to return - Invalid Age 
    public static final String  INVALID_AGE_MESSAGE = 'Invalid Age';
    
    public static final String YES_VALUE = 'Yes';
    public static final String NO_VALUE = 'No';
    public static final String NA_VALUE = 'NA';
    
    public static final String NEW_ASP_APPLICATION_FEE_DESCRIPTION = 'Authorisation application fee';
    public static final String NEW_ASP_APPLICATION_FEE_PAYMENT_STATUS = 'Payment Due';
    public static final String NEW_ASP_APPLICATION_TRANSACTION_TYPE = 'Authorisation Application Fee';
    public static final String RENEWAL_ASP_APPLICATION_FEE_DESCRIPTION = 'Authorisation renewal application fee';
    public static final String RENEWAL_ASP_APPLICATION_TRANSACTION_TYPE = 'Authorisation Renewal Fee';
    
    public static final String NEW_TAXI_APPLICATION_FEE_DESCRIPTION = 'Taxi licence application fee';
    public static final String NEW_TAXI_APPLICATION_FEE_PAYMENT_STATUS = 'Payment Due';
    public static final String NEW_TAXI_APPLICATION_TRANSACTION_TYPE = 'Licence Application Fee';
    public static final String RENEWAL_TAXI_APPLICATION_FEE_DESCRIPTION = 'Taxi licence renewal application fee';
    public static final String RENEWAL_TAXI_APPLICATION_TRANSACTION_TYPE = 'Licence Renewal Application Fee';
    public static final String RECURRING_RENEWAL_FEE_DESCRIPTION = 'Taxi licence monthly recurring fee';
    
    public static final String TAXI_TRANSFER_APPLICATION_LEVY_DUE_DESCRIPTION = 'Taxi transfer levy';
    public static final String TAXI_TRANSFER_APPLICATION_LEVY_DUE_STATUS = 'Payment Due';
    public static final String TAXI_TRANSFER_APPLICATION_TRANSACTION_TYPE = 'Licence Transfer Levy';
    
    public static final String NEW_APPLICATION_TYPE = 'New';
    public static final String RENEWAL_APPLICATION_TYPE = 'Renew';
    
    public static final String MONTHLY_PAYMENT_FREQUENCY = 'Monthly';
    
    public static final String RENEWAL_TAXI_APPLICATION_SUBJECT = 'Renewal Licence Application';
    public static final String NONRENEWAL_TAXI_APPLICATION_SUBJECT = 'Non Renewal Expiry';
    
    public static final String TAXI_LEVEL_2_QUEUE_DEV_NAME = 'Taxi_Support_Level_2';
    
    public static final String PAYMENT_REJECTED_STATUS = 'Payment Rejected';
    public static final String PAYMENT_PAID_IN_FULL_STATUS = 'Paid in Full';
    public static final String PAYMENT_PAID_UNCLEARED_STATUS = 'Payment Uncleared';
    public static final String PAYMENT_DUE_STATUS = 'Payment Due';
    public static final String PAYMENT_METHOD_DIRECT_DEBIT = 'Direct Debit';
    public static final String PAYMENT_METHOD_CHEQUE =  'Bank Cheque';
    public static final String PAYMENT_METHOD_BPAY = 'BPay';
    
    public static final Set<String> PAYMENT_DUE_STATUS_VALUES = new Set<String>{'Payment Due', 'Payment Uncleared', 'Payment Rejected'};
        
        public static final String TAXI_LICENCE_EXPIRATION_CASE_SUBJECT = 'Taxi Licence Expiration';        
    
    //Queue
    public static final String QUEUE = 'Queue';
    
    public static final String ASP_LEVEL_1_QUEUE_DEV_NAME = 'ASP_Support_Tier_1';
    
    public static final String ASP_LEVEL_2_QUEUE_DEV_NAME = 'ASP_Support_Tier_2';
    
    public static final String TAXI_LEVEL_1_QUEUE_DEV_NAME = 'Taxi_Support_Level_1';
    
    public static final String RELATED_CONTACT_RECORD_TYPE_CONTACTS = 'Contacts';
    
    public static final String RELATED_CONTACT_RECORD_TYPE_INDIVIDUAL = 'Individual';
    
    public static final String NSW_BUSINESS_HRS_NAME = 'NSW Business Hours';
    
    public static final String PAYMENT_METHOD_CREDIT_DEBIT_CARD = 'Credit Card/Debit Card';
    
    public static final String CASE_SUBTYPE_REJECTED_PAYMENT = 'Rejected Payment';
    public static final String CASE_SUBJECT_RECURRING_PAYMENT_REJECTED = 'Recurring payment rejected for licence.';
    
    public static final Map<String, String> PAYMENT_METHOD_FACADE_MAPPING = new Map<String, String>{'Credit Card/Debit Card' => 'CREDIT_CARD', 'Direct Debit' => 'DIRECT_DEBIT'};
        
        /* Order status mapping */
        public static final Map<String, String> ORDER_STATUS = new Map<String, String> {'DUE' => 'Payment Due', 'UNCLEARED' => 'Payment Uncleared', 'SUCCESS' => 'Paid in Full',  'REJECTED' => 'Payment Rejected', 'CANCELLED' => 'Payment Cancelled'};
            
            public static final String DVD_ENTITY_TYPE_DRIVER = 'Drivers';
    public static final String DVD_ENTITY_TYPE_VEHICLE = 'Vehicles';
    
    public static final Integer NUMBER_OF_DIRECT_DEBIT_PAYMENTS_TO_PROCESS = 500;
    public static final Integer ABA_HEADER_REEL_SEQUENCE_NUMBER = 1;
    public static final String TAXI_LICENCE_TENDER = 'Tender Applications';
    
    public static final String WAT_APPLICATION_SUB_TYPE = 'WAT Application';
    
    /* Case Type */
    public static final String CASE_TYPE_ASP = 'Service Provider Application';
    public static final String CASE_TYPE_TAXI = 'Taxi';
    
    public static final String CPI_INDEX_METADATA_NAME = 'Consumer_Price_Index';
    public static final String RENEWAL_PRICE_FORMULA_BASE = 'Base';
    public static final String RENEWAL_PRICE_FORMULA_BASE_CPI = 'Base+CPI';
    
    //Authorisation Status Lapsed
    public static final String AUTH_STATUS_LAPSED = 'Lapsed';
    
    //Taxi+ASP Profile Name
    public static final String Taxi_ASP_PROFILE_NAME = 'Taxi And ASP'; 
    
    //P2P Operations Level 1 profile Name
    public static final String P2P_OPERATIONS_LEVEL_1 = 'P2P Operations Level 1';
    
    //P2P Operations Level 2 profile Name
    public static final String P2P_OPERATIONS_LEVEL_2 = 'P2P Operations Level 2';
    
    //P2P Operations Level 3 profile Name
    public static final String P2P_OPERATIONS_LEVEL_3 = 'P2P Operations Level 3';
    
    //P2P Compliance profile Name
    public static final String P2P_COMPLIANCE = 'P2P Compliance';
    
    //Taxi+Account Manager Profile Name
    public static final String Taxi_ACCOUNT_MANAGER_PROFILE_NAME = 'Taxi And Account Manager';
    
    public static final String CUSTOMER_COMMUNITY_USER_TYPE = 'CspLitePortal';
    
    public static final String LICENCE_RENEWAL_TRANSACTION_TYPE = 'Licence Renewal Application Fee';
    public static final String PAYMENT_METHOD_CONTACT_P2P = 'Contact P2P Commission';
    public static final String LICENCE_RENEWAL_PRODUCT_NAME_PREFIX = 'Taxi Renewal Application';
    public static final String LICENCE_TYPE_ANNUAL = 'Annual';
    public static final String ANNUAL_TAXI_LICENCE_PRODUCT_NAME = 'Taxi Licence - Annual';
    public static final String LICENCE_TYPE_ORDINARY = 'Ordinary';
    public static final String ORDINARY_TAXI_LICENCE_PRODUCT_NAME = 'Taxi Licence - Ordinary';
    public static final String LICENCE_TYPE_SHORT_TERM = 'Short Term';
    public static final String SHORT_TERM_TAXI_LICENCE_PRODUCT_NAME = 'Taxi Licence - Short Term';
    public static final String DOCUMENT_DELIVERY_PREFERENCE_EMAIL = 'Email';
    
    public static final String DEFAULT_OWNER = 'Default_Owner';
    public static final String INVITE_BUYER_MISSING_ACT_ERR = 'Please associate the buyer case with its corresponding account and contact.';
    public static final String INVITE_BUYER_MISSING_LEVY_FEE = 'Please enter Licence Market Value and Levy Due.';
    
    public static final String TAXI_LICENCE_RECURRING_FEE_DESC = 'Taxi licence recurring fee';
    public static final String TAXI_LICENCE_RENEWAL_DESC = 'Taxi renewal';
    
    public static final String INVOCATION_CONTEXT_INTERNAL_STAFF = 'internal staff';
    public static final String INVOCATION_CONTEXT_ASP = 'ASP';
    public static final String INVOCATION_CONTEXT_TAXI = 'Taxi';
    
    //ABA generation for recurring payment trace record BSB + Account Number
    public static final String ABA_TRACE_RECORD_BSB = '032-797';
    public static final String ABA_TRACE_RECORD_ACCOUNT_NUMBER = '220962';
    public static final String ABA_TRACE_RECORD_ACCOUNT_NAME = 'P2P Trace Accoun';
    
    public static final String INDEX_LOGIN_PAGE_MESSAGE_PRIOR_OUTAGE = 'Index_Login_Page_Message_Prior_Outage';
    public static final String INDEX_LOGIN_PAGE_MESSAGE_DURING_OUTAGE = 'Index_Login_Page_Message_During_Outage';
    public static final String DVD_DASHBOARD_MESSAGE = 'DVD_Dashboard_Message';
    
    // Edit Contact Case 
    public static final String EDIT_CONTACT_CASE_DESCRIPTION = 'Access Request';
    public static final String CASE_MAINTAIN_REQUEST_EDIT_CONTACT = 'Access Request';
    
    // Add, Remove, Edit Contact - Case Origin
    public static final String CASE_ORIGIN_INDUSTRY_PORTAL = 'Industry Portal';
    public static final String CASE_ORIGIN_WEB = 'Web';
    
    public static final String ACTIVE_CONTACT_STATUS = 'Active';
    public static final String INACTIVE_CONTACT_STATUS = 'Inactive';
    
    public static final String ADD_CONTACT_REQUEST = 'Add Contact Request';
    
    //Levy Status values
    public static final String STATUS_ACTIVE = 'Active';
    public static final String STATUS_SUPERSEDED = 'Superseded';
    public static final String STATUS_REJECTED = 'Rejected';
    
    public static final String SUB_STATUS_PENDING_P2P = 'Pending with P2P';
    public static final String SUB_STATUS_PENDING_RNSW = 'Pending - Revenue NSW';
    public static final String SUB_STATUS_COMPLETED = 'Completed';
    
    public static final String DDR_SERVICE_AGREEMENT_NAME = 'DDR_Service_Agreement';
    
    public static final String TRIP_OVER_600 = 'Over 600';
    
    public static final String LEVY_PROFILE_NAME = 'Levy';
    
    
    //Legislation Status & Record Type
    public static final String LEG_STATUS_ACTIVE = 'Active';
    public static final String LEG_STATUS_INACTIVE = 'Inactive';
    
    //Case Sub type
    public static final String Levy_Exemption_Case_SUB_TYPE = 'Levy Exemption';
    public static final String Levy_Rebate_Case_SUB_TYPE = 'Levy Rebate';
    
    //Case Subject
    public static final String Levy_Exemption_Subject = 'Request for Levy Exemption';
    public static final String Levy_Rebate_Subject = 'Request for Levy Rebate';
    
    //Levy Case Record Type Name
    public static final String Levy_Administration_CASE_RECORD_TYPE_NAME = 'Levy Administration';
    public static final String Levy_Administration_CASE_RECORD_TYPE_DEV_NAME = 'Levy_Administration';
    public static final String Levy_OBJECTION_CASE_RECORD_TYPE_NAME = 'Levy Objection';
    public static final String Levy_OBJECTION_CASE_RECORD_TYPE_DEV_NAME = 'Levy_Objection';
    
    //Levy Administration Case Related Constants 
    public static final String CASE_STATUS_ASSESSMENT_IN_PROGRESS = 'Assessment In-Progress';
    public static final String CASE_STATUS_IN_PROGRESS = 'In Progress';
    public static final String CASE_TYPE_PASSENGER_SERVICE_LEVY = 'Passenger Service Levy';
    public static final String CASE_SUBTYPE_HELD_ASSESSMENT = 'Held Assessment';
    public static final String CASE_STATUS_NEW = 'New';
    public static final String CASE_SUBTYPE_NON_REGISTRATION = 'Non Registration';
    
    public static final String REVENUE_NSW_STATUS_NA = 'N/A';
    public static final String REVENUE_NSW_STATUS_PENDING = 'Pending';
    public static final String REVENUE_NSW_STATUS_SUCCESS = 'Success';
    public static final String REVENUE_NSW_STATUS_ERROR = 'Error';
    
    public static final String REGISTRATION_APPROVED = 'Approved';
    public static final String REGISTRATION_REJECTED = 'Rejected';
    public static final String REGISTRATION_DECISION_PENDING = 'Decision Pending';
    
    public static final String ASSESSMENT_TYPE_REASSESSMENT = 'Reassessment';
    public static final String ASSESSMENT_TYPE_ASSESSMENT = 'Assessment';
    public static final String ASSESSMENT_TYPE_REASSESSMENT_COMPROMISED = 'Reassessment-Compromise';
    public static final String ASSESSMENT_TYPE_ASSESSMENT_COMPROMISED = 'Assessment-Compromise';
    //Authorisation 
    public static final String AUTHORISATION_STATUS_DECISION_PENDING = 'Decision Pending';
    
    //Assessment 
    public static final String ASSESSMENT_STATUS_OPEN = 'Open';
    public static final String ASSESSMENT_STATUS_ASSESSED = 'Assessed';
    public static final String ASSESSMENT_STATUS_HELD = 'Held';
    public static final String ASSESSMENT_STATUS_ISSUED = 'Issued';
    public static final String Assessment_STATUS_OUTSTANDING = 'Outstanding';
    public static final String Assessment_STATUS_SUBMITTED = 'Submitted';
    public static final String Assessment_STATUS_ERROR = 'Error';
    public static final String Assessment_STATUS_Closed = 'Closed';
    public static final String ASSESSMENT_STATUS_SUPERSEDED = 'Superseded';
    
    //Assessment
    public static final String ASSESSMENT_REVENUE_RESPONSE_TYPE_Success = 'Success';
    public static final String ASSESSMENT_REVENUE_RESPONSE_TYPE_Error = 'Error';
    
    public static final String LEVY_OBJECTION_CASE_SUB_TYPE = 'Reassessment - Objection';
    public static final String LEVY_OBJECTION_SUBJECT = 'Reassessment Objection';
    
    //Taxi License Administration case record type name 
    public static final String TAXI_LICENSE_ADMINISTRATION_CASE_RECORD_TYPE_NAME ='Taxi License Administration';
    
    //Taxi License Administration case record type name dev name
    public static final String TAXI_LICENSE_ADMINISTRATION_CASE_RECORD_TYPE_NAME_DEV_NAME ='Taxi_License_Administration';
    
    //Taxi License Administration case record type Cancel-Paired,Surrender-Paired and Unsuspend SUB_TYPE
    public static final String CASE_SUB_TYPE_CANCEL_PAIRED = 'Cancel-Paired';
    public static final String CASE_SUB_TYPE_SURRENDER_PAIRED = 'Surrender-Paired';
    public static final String CASE_SUB_TYPE_UNSUSPEND = 'Unsuspend';
    public static final String CASE_SUB_TYPE_UNSUSPEND_PAIRED = 'UnSuspend-Paired';
    
    //Taxi License Adminsitration Authorisation Licence Class picklist values
    public static final String TAXI_LICENCE_AUTHORISATION_CLASS_TX03 = 'TX03';
    public static final String TAXI_LICENCE_AUTHORISATION_CLASS_TX03WAT = 'TX03WAT';
    
    public static final String CASE_SUBJECT_INITIAL_ASSESSMENT = 'Initial Assessment';
    public static final String CASE_SUB_TYPE_ASSESSMENT_OTHER = 'Assessment - Other';
    public static final String CASE_SUB_TYPE_ASSESSMENT_AUDIT_AND_COMPLIANCE = 'Assessment - Audit & Compliance';
    public static final String CASE_DESCRIPTION_INITIAL_ASSESSMENT = 'Initial assessment for the period of';
    public static final String CASE_SUBJECT_INITIAL_REASSESSMENT = 'Reassessment';
    public static final String CASE_SUB_TYPE_REASSESSMENT_OTHER = 'Reassessment - Other';
    public static final String CASE_SUB_TYPE_REASSESSMENT_AUDIT_AND_COMPLIANCE = 'Reassessment - Audit & Compliance';
    public static final String CASE_DESCRIPTION_INITIAL_REASSESSMENT = 'Reassessment for the period of';
    
    //Tax Payer Registration
    public static final String TAX_PAYER_REGISTRATION_REVENUE_RESPONSE_TYPE_Success = 'Success';
    public static final String TAX_PAYER_REGISTRATION_REVENUE_RESPONSE_TYPE_Error = 'Error';
    
    public static final String  INVALID_LAST_NAME = 'Last name';
    public static final String  INVALID_LAST_NAME_MESSAGE = 'Invalid Last Name';
    
    public static final String Taxi_Awaiting_Plates_Case_SUB_TYPE = 'Awaiting Plates';
    
    public static final String ACCOUNT_MANAGER_LEVY_PROFILE_NAME = 'Account Manager And Levy';
    public static final String TAXI_ACCOUNT_MANAGER_LEVY_PROFILE_NAME = 'Taxi And Account Manager And Levy';
    
    // Case Sub Status Expired
    public static final String CASE_SUB_STATUS_EXPIRED = 'Expired';
    
    // Case Sub Type Expiry - Renewable
    public static final String CASE_SUB_TYPE_EXPIRY_RENEWABLE= 'Expiry - Renewable';
    
    //Taxi Licence Authorisation Record Type Dev Name
    public static final String TAXI_LICENCE_ADMINISTRATION_RECORD_TYPE_DEV_NAME ='Taxi_License_Administration';
    
    // Case Sub Status Cancelled
    public static final String CASE_SUB_STATUS_CANCELLED = 'Cancelled';
    
    // Case Sub Type Surrender
    public static final String CASE_SUB_TYPE_SURRENDER= 'Surrender';
    
    // Case Sub Type Cancel
    public static final String CASE_SUB_TYPE_CANCEL= 'Cancel';
    
    // Levy Amount Calculation Methods
    public static final String LEVY_CALCULATION_METHOD_ASSESSED_MANUALLY = 'Assessed Manually';
    public static final String LEVY_CALCULATION_METHOD_ASSESSED_BY_SF = 'Assessed by SalesForce';
    public static final String LEVY_CALCULATION_METHOD_ESTIMATED_BY_SF = 'Estimated by SalesForce';
    
    public static final String CASE_SUB_TYPE_SUSPEND_PAIRED = 'Suspend-Paired';
    
    public static final String CASE_SUBJECT_SUSPEND_PAIRED = 'Suspension of Paired Taxi license';
    public static final String CASE_DESCRIPTION_SUSPEND_PAIRED = 'Suspension of Paired Taxi license';
    public static final String CASE_SUBJECT_NEXUS_SUSPEND_PAIRED = 'Suspension of a Nexus Taxi license';
    public static final String CASE_DESCRIPTION_NEXUS_SUSPEND_PAIRED = 'Suspension of a Nexus Taxi license';
    
    public static final String CASE_SUBJECT_UNSUSPEND_PAIRED = 'UnSuspension of Paired Taxi license';
    public static final String CASE_DESCRIPTION_UNSUSPEND_PAIRED = 'UnSuspension of Paired Taxi license';
    public static final String CASE_SUBJECT_NEXUS_UNSUSPEND_PAIRED = 'UnSuspension of a Nexus Taxi license';
    public static final String CASE_DESCRIPTION_NEXUS_UNSUSPEND_PAIRED = 'UnSuspension of a Nexus Taxi license';
    
    public static final String AUTHORISATION_REQUEST_TYPE_SUSPEND_PAIRED = 'Suspend-Paired';
    public static final String AUTHORISATION_REQUEST_TYPE_UNSUSPEND_PAIRED = 'UnSuspend-Paired';
    
    public static final String PAYMENT_METHOD_MONEY_ORDER = 'Money Order';
    
    public static final String ASSESSMENT_NO_CHANGE_REQUIRED = 'No Change Required';
    
    public static final String RETURN_NOT_RECEIVED = 'Return is not received';
    
    // Case Record Type Name
    public static final String CASE_RECORDTYPE_LABEL_NOTIFIABLE_OCCURRENCE = 'Notifiable Occurrence';
    
    /* Audit Related Constants */
    //Audit Record types for Account and Contact Object
    public static final String ACCOUNT_RECORDTYPE_DEV_NAME_AUDIT_VENDOR ='Audit_Vendor';
    public static final String ACCOUNT_RECORDTYPE_NAME_AUDIT_VENDOR ='Audit Vendor';
    public static final String CONTACT_RECORDTYPE_DEV_NAME_AUDIT_VENDOR ='Audit_Vendor';
    public static final String CASE_RECORDTYPE_DEV_NAME_AUDIT ='Audit';
    
    public static final String AUDITOR_STATUS_ACTIVE = 'Active';
    public static final String AUDITOR_STATUS_INACTIVE = 'Inactive';
    public static final String AUDITOR_TYPE_INTERNAL = 'Internal';
    public static final String AUDITOR_TYPE_EXTERNAL = 'External';
    
    public static final String VENDOR_AUDITOR_ROLE_NAME = 'Vendor Auditors';
    public static final String TEAM_ACCOUNT_AUDITOR_ROLE_NAME = 'Auditor';
    
    public static final String FIELDKO_APP_NAMESPACE = 'ArxxusRFMv1';
    public static final String FIELDKO_NATIVE_APP_NAMESPACE = 'FieldKoNativev1';
    public static final String FIELDKO_NATIVE_PERMISSION_SET = 'FieldKo_Native_Permission_Set';
    public static final String FIELDKO_REPRESENTATIVE_PERMISSION_SET = 'RFM_Representative_Permission_Set';
    public static final String FIELDKO_REPRESENTATIVE_CLONE_PERMISSION_SET = 'RFM_Representative_Permission_Set_clone';
    
    
    public static final String SAFETY_FULL_AUDIT_SUB_TYPE = 'Safety Audit - Full';
    public static final String LEVY_AUDIT_SUB_TYPE = 'Levy Audit';
    public static final String SAFETY_SELECTED_AUDIT_SUB_TYPE = 'Safety Audit - Selected';
    
    public static final String CASE_SUBSTATUS_AUDIT_PENDING = 'Audit Pending';
    public static final String CASE_SUBSTATUS_AUDIT_COMPLETED = 'Audit Completed';
    public static final String CASE_SUBSTATUS_FINDINGS_PENDING = 'Findings Pending';
    public static final String CASE_SUBSTATUS_FINDINGS_COMPLETED = 'Findings Completed';
    
    public static final String VISIT_STATUS_NOT_STARTED = 'Not Started';
    public static final String VISIT_STATUS_COMPLETED = 'Completed';
    public static final String VISIT_STATUS_IN_PROGRESS = 'In Progress';
    public static final String USER_ROLE_P2P_EXE_DIRECTOR = 'P2P Executive Director';    
    
    public static final String RELATED_CONTACT_AGENT_AGREEMENT_RECORD_TYPE_DEV_NAME = 'Agent_Agreement';
    public static final String TAXI_AGENT_USERS_PROFILE_NAME = 'Taxi Agent Users';
    public static final String CASE_AGENT_REGISTRATION_RECORD_TYPE_DEV_NAME = 'Agent_Registration';
    public static final String AUTHORISATION_AGENT_AGREEMENT_TYPE = 'Transfer Only';
    public static final String AUTHORISATION_AGENT_AGREEMENT_TYPE_FULL_ACCESS = 'Full Access';
    public static final String CASE_SUB_TYPE_AGENT_REGISTRATION = 'Agent Account Application';
    public static final String CASE_AGENT_REGISTRATION_RECORD_TYPE = 'Agent Registration';

    public static final String RELATED_CONTACT_INDIVIDUAL_RECORD_TYPE = 'Individual';
    public static final String RELATED_CONTACT_CORPORATE_RECORD_TYPE = 'Corporate';
    
    public static final String AGENT_LICENCE_AGREEMENT_SUB_TYPE = 'Agent Agreement Registration';
    
    // Taxi Agent Manager Details Component Attribute Value relatedContactType
    public static final String RELATED_CONTACT_RELATED_CONTACT_TYPE = 'TaxiAgentManagerDetails';
    
    // Related Contact Record Type Name
    public static final String RELATED_CONTACT_INDIVIDUAL_AGENT_RECORD_TYPE = 'Individual Agent';
    public static final String RELATED_CONTACT_CORPORATE_AGENT_RECORD_TYPE = 'Corporate Agent';
    
    //Publich Group and Queue
    public static final String TAXI_SUPPORT_LEVEL_1_QUEUE = 'Taxi Support Level 1';
    
      // Sanction Ncat Review Record Type Name
      public static final String NCAT_REVIEW_RECORD_TYPE = 'NCAT Review';
    
    //Sanction  NCAT case sub type
    public static final String  NCAT_REVIEW_CASE_SUB_TYPE = 'NCAT Review';
    
    // ASP Auth Renewal Case Subject
    public static final String ASP_AUTH_RENEWAL_CASE_SUBJECT = 'Renewal Authorisation Application';
    
    public static final string CASE_RECORDTYPE_CUSTOMER_ENQUIRY_DEVNAME = 'Customer_Enquiry';
    public static final string CUSTOMER_ENQUIRY_SUB_TYPE= 'Customer Query';
      
    public static final String UNAUTHORISED_ACCESS = 'Unauthorised Access'; 
    
    public static final String CASE_SUB_STATUS_REVIEW_PENDING = 'Review Pending';
    
    public static final String REVOKE_AGREEMENT_CASE_SUB_TYPE = 'Revoke Agreement';
    
    //case origin = console
    public static final String CASE_ORIGIN_CONSOLE = 'Console';
    
    public static final String INADEQUATE_ASSESSMENT_RECORDS = 'Inadequate records';
    
    public static final String CASE_RECORDTYPE_CUSTOMER_ENQUIRY = 'Customer Enquiry';
    
    //Audit External Auditor new Permission sets
    public static final String FIELDKO_BASIC_REPRESENTATIVE_PERMISSION_SET = 'RFM_Basic_Representative_Permission_Set';
    public static final String FIELDKO_BASIC_REPRESENTATIVE_CLONE_PERMISSION_SET = 'RFM_Basic_Representative_Permission_Set_Clone';
    
    //Audit Case Sub Status
    public static final String CASE_SUB_STATUS_REPORT_APPROVAL = 'Report Approval';
    
    
    //--------Missing from SIT compared to UAT-------
    public static final String Sanctions_Level_2_QUEUE_DEV_NAME = 'Sanctions_Level_2';
    
    //Law Part Code statuses
    public static final String LAW_PART_CODE_STATUS_APPROVED = 'Approved';
    
    public static final String SANCTIONS_OPERATIONS_STAFF_LEVEL_2_LEVEL_3_PERMISSION_SET = 'Sanctions_Operations_Staff_level_2_level_3';
    public static final String ADMIN_READ_ONLY_PROFILE_NAME = 'System Admin Read Only';
    
    //Sanctions Permission Sets
    public static final String SANCTIONS_OPERATIONS_STAFF_PERMISSION_SET = 'Sanctions_Operations_Staff';
    
    //Overturn case type
    public static final String OVERTURN_CASE_TYPE = 'Overturn';
    
    //Criminal Offence Investigation case sub type
    public static final String CRIMINAL_OFFENCE_INVESTIGATION_SUB_TYPE = 'Criminal Offence Investigation';
    
    //SANCTIONS_LEVEL_1 queue dev name
    public static final String SANCTIONS_LEVEL_1_QUEUE_DEV_NAME = 'Sanctions_Level_1';
    
    //Case Record type Criminal Offence Investigation Dev Name
    public static final String Criminal_Offence_Investigation_CASE_RECORD_TYPE_DEV_NAME = 'Criminal_Offence_Investigation';
   
    //Case Record type Criminal Offence Investigation Name
    public static final String Criminal_Offence_Investigation_CASE_RECORD_TYPE_NAME = 'Criminal Charge Investigation';
      
    public static final String Criminal_Offence_CASE_RECORD_TYPE_DEV_NAME = 'Criminal_Offence';
    
    public static final String Criminal_Offence_CASE_RECORD_TYPE_NAME = 'Criminal Charge';
    
    public static final String DECISION_COMPLETE_SUB_STATUS = 'Decision Complete';
    
    public static final String CHARGE_RETAINED = 'Record Retained';
    public static final String CHARGE_CORRECTED = 'Record Corrected';
    
    //permission set name Data_Exchange_Service_Delivery
    public static final String DATA_EXCHANGE_SERVICE_DELIVERY = 'Data_Exchange_Service_Delivery';
    
    public static final String BYPASS_PORTAL_DOWNTIME_PERMISSION = 'Bypass_Downtime_Checks';
    
    public static final String CASE_SUB_STATUS_DID_NOT_PROCEED = 'Did not Proceed';
    
    public static final String CASE_SUB_STATUS_WAITING_FOR_PLATES = 'Waiting for plates';
    
    public static final String DOC_DELIVERY_PREFERENCE_NOTICE_ADDR = 'Notice Address';
    public static final String DOC_DELIVERY_PREFERENCE_LETTER = 'Letter';
    
    //Noitce Record Type
    //public static final Set<String> COMPLIANCE_NOTICE_RECORD_TYPE = new Set<String>{'Audit Notice', 'Improvement Notice', 'Notice to Inspect','Notice to Produce', 'Prohibition Notice','Require Information (Tax)'};
    
    //Notice Status
    public static final Set<String> NOTICE_CLOSED_STATUS = new Set<String>{'Closed','Cancelled'};
    //Case Record Type valid for Notice closed check
    public static final Set<String> COMPLIANCE_Case_RECORD_TYPE = new Set<String>{'Advisory_Visit', 'Audit', 'Enquiry','Investigation', 'Notifiable_Occurrence','Vehicle_Check'};
}