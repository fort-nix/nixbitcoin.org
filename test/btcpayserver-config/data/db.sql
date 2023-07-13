--
-- PostgreSQL database dump
--

-- Dumped from database version 11.20
-- Dumped by pg_dump version 11.20

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: btcpaydb; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE btcpaydb WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8';


ALTER DATABASE btcpaydb OWNER TO postgres;

\connect btcpaydb

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: AddressInvoices; Type: TABLE; Schema: public; Owner: btcpayserver
--

CREATE TABLE public."AddressInvoices" (
    "Address" text NOT NULL,
    "InvoiceDataId" text,
    "CreatedTime" timestamp with time zone
);


ALTER TABLE public."AddressInvoices" OWNER TO btcpayserver;

--
-- Name: ApiKeys; Type: TABLE; Schema: public; Owner: btcpayserver
--

CREATE TABLE public."ApiKeys" (
    "Id" character varying(50) NOT NULL,
    "StoreId" character varying(50),
    "Type" integer DEFAULT 0 NOT NULL,
    "UserId" character varying(50),
    "Label" text,
    "Blob" bytea,
    "Blob2" jsonb
);


ALTER TABLE public."ApiKeys" OWNER TO btcpayserver;

--
-- Name: Apps; Type: TABLE; Schema: public; Owner: btcpayserver
--

CREATE TABLE public."Apps" (
    "Id" text NOT NULL,
    "AppType" text,
    "Created" timestamp with time zone NOT NULL,
    "Name" text,
    "Settings" text,
    "StoreDataId" text,
    "TagAllInvoices" boolean DEFAULT false NOT NULL
);


ALTER TABLE public."Apps" OWNER TO btcpayserver;

--
-- Name: AspNetRoleClaims; Type: TABLE; Schema: public; Owner: btcpayserver
--

CREATE TABLE public."AspNetRoleClaims" (
    "Id" integer NOT NULL,
    "ClaimType" text,
    "ClaimValue" text,
    "RoleId" text NOT NULL
);


ALTER TABLE public."AspNetRoleClaims" OWNER TO btcpayserver;

--
-- Name: AspNetRoles; Type: TABLE; Schema: public; Owner: btcpayserver
--

CREATE TABLE public."AspNetRoles" (
    "Id" text NOT NULL,
    "ConcurrencyStamp" text,
    "Name" character varying(256),
    "NormalizedName" character varying(256)
);


ALTER TABLE public."AspNetRoles" OWNER TO btcpayserver;

--
-- Name: AspNetUserClaims; Type: TABLE; Schema: public; Owner: btcpayserver
--

CREATE TABLE public."AspNetUserClaims" (
    "Id" integer NOT NULL,
    "ClaimType" text,
    "ClaimValue" text,
    "UserId" text NOT NULL
);


ALTER TABLE public."AspNetUserClaims" OWNER TO btcpayserver;

--
-- Name: AspNetUserLogins; Type: TABLE; Schema: public; Owner: btcpayserver
--

CREATE TABLE public."AspNetUserLogins" (
    "LoginProvider" character varying(255) NOT NULL,
    "ProviderKey" character varying(255) NOT NULL,
    "ProviderDisplayName" text,
    "UserId" text NOT NULL
);


ALTER TABLE public."AspNetUserLogins" OWNER TO btcpayserver;

--
-- Name: AspNetUserRoles; Type: TABLE; Schema: public; Owner: btcpayserver
--

CREATE TABLE public."AspNetUserRoles" (
    "UserId" text NOT NULL,
    "RoleId" text NOT NULL
);


ALTER TABLE public."AspNetUserRoles" OWNER TO btcpayserver;

--
-- Name: AspNetUserTokens; Type: TABLE; Schema: public; Owner: btcpayserver
--

CREATE TABLE public."AspNetUserTokens" (
    "UserId" text NOT NULL,
    "LoginProvider" character varying(64) NOT NULL,
    "Name" character varying(64) NOT NULL,
    "Value" text
);


ALTER TABLE public."AspNetUserTokens" OWNER TO btcpayserver;

--
-- Name: AspNetUsers; Type: TABLE; Schema: public; Owner: btcpayserver
--

CREATE TABLE public."AspNetUsers" (
    "Id" text NOT NULL,
    "AccessFailedCount" integer NOT NULL,
    "ConcurrencyStamp" text,
    "Email" character varying(256),
    "EmailConfirmed" boolean NOT NULL,
    "LockoutEnabled" boolean NOT NULL,
    "LockoutEnd" timestamp with time zone,
    "NormalizedEmail" character varying(256),
    "NormalizedUserName" character varying(256),
    "PasswordHash" text,
    "PhoneNumber" text,
    "PhoneNumberConfirmed" boolean NOT NULL,
    "SecurityStamp" text,
    "TwoFactorEnabled" boolean NOT NULL,
    "UserName" character varying(256),
    "RequiresEmailConfirmation" boolean DEFAULT false NOT NULL,
    "Created" timestamp with time zone,
    "DisabledNotifications" text,
    "Blob" bytea,
    "Blob2" jsonb
);


ALTER TABLE public."AspNetUsers" OWNER TO btcpayserver;

--
-- Name: CustodianAccount; Type: TABLE; Schema: public; Owner: btcpayserver
--

CREATE TABLE public."CustodianAccount" (
    "Id" character varying(50) NOT NULL,
    "StoreId" character varying(50) NOT NULL,
    "CustodianCode" character varying(50) NOT NULL,
    "Name" character varying(50),
    "Blob" bytea,
    "Blob2" jsonb
);


ALTER TABLE public."CustodianAccount" OWNER TO btcpayserver;

--
-- Name: Fido2Credentials; Type: TABLE; Schema: public; Owner: btcpayserver
--

CREATE TABLE public."Fido2Credentials" (
    "Id" text NOT NULL,
    "Name" text,
    "ApplicationUserId" text,
    "Blob" bytea,
    "Type" integer NOT NULL,
    "Blob2" jsonb
);


ALTER TABLE public."Fido2Credentials" OWNER TO btcpayserver;

--
-- Name: Files; Type: TABLE; Schema: public; Owner: btcpayserver
--

CREATE TABLE public."Files" (
    "Id" text NOT NULL,
    "FileName" text,
    "StorageFileName" text,
    "Timestamp" timestamp without time zone NOT NULL,
    "ApplicationUserId" text
);


ALTER TABLE public."Files" OWNER TO btcpayserver;

--
-- Name: Forms; Type: TABLE; Schema: public; Owner: btcpayserver
--

CREATE TABLE public."Forms" (
    "Id" text NOT NULL,
    "Name" text,
    "StoreId" text,
    "Config" jsonb,
    "Public" boolean NOT NULL
);


ALTER TABLE public."Forms" OWNER TO btcpayserver;

--
-- Name: InvoiceEvents; Type: TABLE; Schema: public; Owner: btcpayserver
--

CREATE TABLE public."InvoiceEvents" (
    "InvoiceDataId" text NOT NULL,
    "UniqueId" text NOT NULL,
    "Message" text,
    "Timestamp" timestamp with time zone NOT NULL,
    "Severity" integer DEFAULT 0 NOT NULL
);


ALTER TABLE public."InvoiceEvents" OWNER TO btcpayserver;

--
-- Name: InvoiceSearches; Type: TABLE; Schema: public; Owner: btcpayserver
--

CREATE TABLE public."InvoiceSearches" (
    "Id" integer NOT NULL,
    "InvoiceDataId" character varying(255),
    "Value" text
);


ALTER TABLE public."InvoiceSearches" OWNER TO btcpayserver;

--
-- Name: InvoiceSearches_Id_seq; Type: SEQUENCE; Schema: public; Owner: btcpayserver
--

CREATE SEQUENCE public."InvoiceSearches_Id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."InvoiceSearches_Id_seq" OWNER TO btcpayserver;

--
-- Name: InvoiceSearches_Id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: btcpayserver
--

ALTER SEQUENCE public."InvoiceSearches_Id_seq" OWNED BY public."InvoiceSearches"."Id";


--
-- Name: InvoiceWebhookDeliveries; Type: TABLE; Schema: public; Owner: btcpayserver
--

CREATE TABLE public."InvoiceWebhookDeliveries" (
    "InvoiceId" text NOT NULL,
    "DeliveryId" text NOT NULL
);


ALTER TABLE public."InvoiceWebhookDeliveries" OWNER TO btcpayserver;

--
-- Name: Invoices; Type: TABLE; Schema: public; Owner: btcpayserver
--

CREATE TABLE public."Invoices" (
    "Id" text NOT NULL,
    "Blob" bytea,
    "Created" timestamp with time zone NOT NULL,
    "CustomerEmail" text,
    "ExceptionStatus" text,
    "ItemCode" text,
    "OrderId" text,
    "Status" text,
    "StoreDataId" text,
    "Archived" boolean DEFAULT false NOT NULL,
    "CurrentRefundId" text,
    "Blob2" jsonb
);


ALTER TABLE public."Invoices" OWNER TO btcpayserver;

--
-- Name: LightningAddresses; Type: TABLE; Schema: public; Owner: btcpayserver
--

CREATE TABLE public."LightningAddresses" (
    "Username" text NOT NULL,
    "StoreDataId" text NOT NULL,
    "Blob" bytea,
    "Blob2" jsonb
);


ALTER TABLE public."LightningAddresses" OWNER TO btcpayserver;

--
-- Name: Notifications; Type: TABLE; Schema: public; Owner: btcpayserver
--

CREATE TABLE public."Notifications" (
    "Id" character varying(36) NOT NULL,
    "Created" timestamp with time zone NOT NULL,
    "ApplicationUserId" character varying(50) NOT NULL,
    "NotificationType" character varying(100) NOT NULL,
    "Seen" boolean NOT NULL,
    "Blob" bytea,
    "Blob2" jsonb
);


ALTER TABLE public."Notifications" OWNER TO btcpayserver;

--
-- Name: OffchainTransactions; Type: TABLE; Schema: public; Owner: btcpayserver
--

CREATE TABLE public."OffchainTransactions" (
    "Id" character varying(64) NOT NULL,
    "Blob" bytea
);


ALTER TABLE public."OffchainTransactions" OWNER TO btcpayserver;

--
-- Name: PairedSINData; Type: TABLE; Schema: public; Owner: btcpayserver
--

CREATE TABLE public."PairedSINData" (
    "Id" text NOT NULL,
    "Label" text,
    "PairingTime" timestamp with time zone NOT NULL,
    "SIN" text,
    "StoreDataId" text
);


ALTER TABLE public."PairedSINData" OWNER TO btcpayserver;

--
-- Name: PairingCodes; Type: TABLE; Schema: public; Owner: btcpayserver
--

CREATE TABLE public."PairingCodes" (
    "Id" text NOT NULL,
    "DateCreated" timestamp without time zone NOT NULL,
    "Expiration" timestamp with time zone NOT NULL,
    "Facade" text,
    "Label" text,
    "SIN" text,
    "StoreDataId" text,
    "TokenValue" text
);


ALTER TABLE public."PairingCodes" OWNER TO btcpayserver;

--
-- Name: PayjoinLocks; Type: TABLE; Schema: public; Owner: btcpayserver
--

CREATE TABLE public."PayjoinLocks" (
    "Id" character varying(100) NOT NULL
);


ALTER TABLE public."PayjoinLocks" OWNER TO btcpayserver;

--
-- Name: PaymentRequests; Type: TABLE; Schema: public; Owner: btcpayserver
--

CREATE TABLE public."PaymentRequests" (
    "Id" text NOT NULL,
    "StoreDataId" text,
    "Status" integer NOT NULL,
    "Blob" bytea,
    "Created" timestamp with time zone DEFAULT '1970-01-01 00:00:00+00'::timestamp with time zone NOT NULL,
    "Archived" boolean DEFAULT false NOT NULL,
    "Blob2" jsonb
);


ALTER TABLE public."PaymentRequests" OWNER TO btcpayserver;

--
-- Name: Payments; Type: TABLE; Schema: public; Owner: btcpayserver
--

CREATE TABLE public."Payments" (
    "Id" text NOT NULL,
    "Blob" bytea,
    "InvoiceDataId" text,
    "Accounted" boolean DEFAULT false NOT NULL,
    "Blob2" jsonb,
    "Type" text
);


ALTER TABLE public."Payments" OWNER TO btcpayserver;

--
-- Name: PayoutProcessors; Type: TABLE; Schema: public; Owner: btcpayserver
--

CREATE TABLE public."PayoutProcessors" (
    "Id" text NOT NULL,
    "StoreId" text,
    "PaymentMethod" text,
    "Processor" text,
    "Blob" bytea,
    "Blob2" jsonb
);


ALTER TABLE public."PayoutProcessors" OWNER TO btcpayserver;

--
-- Name: Payouts; Type: TABLE; Schema: public; Owner: btcpayserver
--

CREATE TABLE public."Payouts" (
    "Id" character varying(30) NOT NULL,
    "Date" timestamp with time zone NOT NULL,
    "PullPaymentDataId" character varying(30),
    "State" character varying(20) NOT NULL,
    "PaymentMethodId" character varying(20) NOT NULL,
    "Destination" text,
    "Blob" bytea,
    "Proof" bytea,
    "StoreDataId" text
);


ALTER TABLE public."Payouts" OWNER TO btcpayserver;

--
-- Name: PendingInvoices; Type: TABLE; Schema: public; Owner: btcpayserver
--

CREATE TABLE public."PendingInvoices" (
    "Id" text NOT NULL
);


ALTER TABLE public."PendingInvoices" OWNER TO btcpayserver;

--
-- Name: PlannedTransactions; Type: TABLE; Schema: public; Owner: btcpayserver
--

CREATE TABLE public."PlannedTransactions" (
    "Id" character varying(100) NOT NULL,
    "BroadcastAt" timestamp with time zone NOT NULL,
    "Blob" bytea
);


ALTER TABLE public."PlannedTransactions" OWNER TO btcpayserver;

--
-- Name: PullPayments; Type: TABLE; Schema: public; Owner: btcpayserver
--

CREATE TABLE public."PullPayments" (
    "Id" character varying(30) NOT NULL,
    "StoreId" character varying(50),
    "Period" bigint,
    "StartDate" timestamp with time zone NOT NULL,
    "EndDate" timestamp with time zone,
    "Archived" boolean NOT NULL,
    "Blob" bytea
);


ALTER TABLE public."PullPayments" OWNER TO btcpayserver;

--
-- Name: Refunds; Type: TABLE; Schema: public; Owner: btcpayserver
--

CREATE TABLE public."Refunds" (
    "InvoiceDataId" text NOT NULL,
    "PullPaymentDataId" text NOT NULL
);


ALTER TABLE public."Refunds" OWNER TO btcpayserver;

--
-- Name: Settings; Type: TABLE; Schema: public; Owner: btcpayserver
--

CREATE TABLE public."Settings" (
    "Id" text NOT NULL,
    "Value" jsonb
);


ALTER TABLE public."Settings" OWNER TO btcpayserver;

--
-- Name: StoreRoles; Type: TABLE; Schema: public; Owner: btcpayserver
--

CREATE TABLE public."StoreRoles" (
    "Id" text NOT NULL,
    "StoreDataId" text,
    "Role" text NOT NULL,
    "Permissions" text[] NOT NULL
);


ALTER TABLE public."StoreRoles" OWNER TO btcpayserver;

--
-- Name: StoreSettings; Type: TABLE; Schema: public; Owner: btcpayserver
--

CREATE TABLE public."StoreSettings" (
    "Name" text NOT NULL,
    "StoreId" text NOT NULL,
    "Value" jsonb
);


ALTER TABLE public."StoreSettings" OWNER TO btcpayserver;

--
-- Name: StoreWebhooks; Type: TABLE; Schema: public; Owner: btcpayserver
--

CREATE TABLE public."StoreWebhooks" (
    "StoreId" character varying(50) NOT NULL,
    "WebhookId" character varying(25) NOT NULL
);


ALTER TABLE public."StoreWebhooks" OWNER TO btcpayserver;

--
-- Name: Stores; Type: TABLE; Schema: public; Owner: btcpayserver
--

CREATE TABLE public."Stores" (
    "Id" text NOT NULL,
    "DerivationStrategy" text,
    "SpeedPolicy" integer NOT NULL,
    "StoreCertificate" bytea,
    "StoreName" text,
    "StoreWebsite" text,
    "StoreBlob" jsonb,
    "DerivationStrategies" jsonb,
    "DefaultCrypto" text
);


ALTER TABLE public."Stores" OWNER TO btcpayserver;

--
-- Name: U2FDevices; Type: TABLE; Schema: public; Owner: btcpayserver
--

CREATE TABLE public."U2FDevices" (
    "Id" text NOT NULL,
    "Name" text,
    "KeyHandle" bytea NOT NULL,
    "PublicKey" bytea NOT NULL,
    "AttestationCert" bytea NOT NULL,
    "Counter" integer NOT NULL,
    "ApplicationUserId" text
);


ALTER TABLE public."U2FDevices" OWNER TO btcpayserver;

--
-- Name: UserStore; Type: TABLE; Schema: public; Owner: btcpayserver
--

CREATE TABLE public."UserStore" (
    "ApplicationUserId" text NOT NULL,
    "StoreDataId" text NOT NULL,
    "Role" text
);


ALTER TABLE public."UserStore" OWNER TO btcpayserver;

--
-- Name: WalletObjectLinks; Type: TABLE; Schema: public; Owner: btcpayserver
--

CREATE TABLE public."WalletObjectLinks" (
    "WalletId" text NOT NULL,
    "AType" text NOT NULL,
    "AId" text NOT NULL,
    "BType" text NOT NULL,
    "BId" text NOT NULL,
    "Data" jsonb
);


ALTER TABLE public."WalletObjectLinks" OWNER TO btcpayserver;

--
-- Name: WalletObjects; Type: TABLE; Schema: public; Owner: btcpayserver
--

CREATE TABLE public."WalletObjects" (
    "WalletId" text NOT NULL,
    "Type" text NOT NULL,
    "Id" text NOT NULL,
    "Data" jsonb
);


ALTER TABLE public."WalletObjects" OWNER TO btcpayserver;

--
-- Name: WalletTransactions; Type: TABLE; Schema: public; Owner: btcpayserver
--

CREATE TABLE public."WalletTransactions" (
    "WalletDataId" text NOT NULL,
    "TransactionId" text NOT NULL,
    "Labels" text,
    "Blob" bytea
);


ALTER TABLE public."WalletTransactions" OWNER TO btcpayserver;

--
-- Name: Wallets; Type: TABLE; Schema: public; Owner: btcpayserver
--

CREATE TABLE public."Wallets" (
    "Id" text NOT NULL,
    "Blob" bytea
);


ALTER TABLE public."Wallets" OWNER TO btcpayserver;

--
-- Name: WebhookDeliveries; Type: TABLE; Schema: public; Owner: btcpayserver
--

CREATE TABLE public."WebhookDeliveries" (
    "Id" text NOT NULL,
    "WebhookId" text NOT NULL,
    "Timestamp" timestamp with time zone NOT NULL,
    "Pruned" boolean NOT NULL,
    "Blob" jsonb NOT NULL
);


ALTER TABLE public."WebhookDeliveries" OWNER TO btcpayserver;

--
-- Name: Webhooks; Type: TABLE; Schema: public; Owner: btcpayserver
--

CREATE TABLE public."Webhooks" (
    "Id" character varying(25) NOT NULL,
    "Blob" bytea NOT NULL,
    "Blob2" jsonb
);


ALTER TABLE public."Webhooks" OWNER TO btcpayserver;

--
-- Name: __EFMigrationsHistory; Type: TABLE; Schema: public; Owner: btcpayserver
--

CREATE TABLE public."__EFMigrationsHistory" (
    "MigrationId" character varying(150) NOT NULL,
    "ProductVersion" character varying(32) NOT NULL
);


ALTER TABLE public."__EFMigrationsHistory" OWNER TO btcpayserver;

--
-- Name: InvoiceSearches Id; Type: DEFAULT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."InvoiceSearches" ALTER COLUMN "Id" SET DEFAULT nextval('public."InvoiceSearches_Id_seq"'::regclass);


--
-- Data for Name: AddressInvoices; Type: TABLE DATA; Schema: public; Owner: btcpayserver
--

COPY public."AddressInvoices" ("Address", "InvoiceDataId", "CreatedTime") FROM stdin;
\.


--
-- Data for Name: ApiKeys; Type: TABLE DATA; Schema: public; Owner: btcpayserver
--

COPY public."ApiKeys" ("Id", "StoreId", "Type", "UserId", "Label", "Blob", "Blob2") FROM stdin;
\.


--
-- Data for Name: Apps; Type: TABLE DATA; Schema: public; Owner: btcpayserver
--

COPY public."Apps" ("Id", "AppType", "Created", "Name", "Settings", "StoreDataId", "TagAllInvoices") FROM stdin;
qJ1NExmDYQLr6MoyZFypeeFgLNj	PointOfSale	2021-11-04 15:47:32.44889+00	donate	{"Title":"Donate","Currency":"USD","Template":"[]","EnableShoppingCart":false,"DefaultView":0,"ShowCustomAmount":true,"ShowDiscount":true,"EnableTips":true,"RequiresRefundEmail":0,"FormId":null,"ButtonText":"Buy for {0}","CustomButtonText":"Pay","CustomTipText":"Do you want to leave a tip?","CustomTipPercentages":[15,18,20],"CustomCSSLink":null,"EmbeddedCSS":null,"Description":null,"NotificationUrl":null,"RedirectUrl":null,"RedirectAutomatically":null,"CheckoutType":0}	9Bf5g2uHFaN21N2ub62fuNCUPrrmiyYSnT4a5iCniHCo	f
\.


--
-- Data for Name: AspNetRoleClaims; Type: TABLE DATA; Schema: public; Owner: btcpayserver
--

COPY public."AspNetRoleClaims" ("Id", "ClaimType", "ClaimValue", "RoleId") FROM stdin;
\.


--
-- Data for Name: AspNetRoles; Type: TABLE DATA; Schema: public; Owner: btcpayserver
--

COPY public."AspNetRoles" ("Id", "ConcurrencyStamp", "Name", "NormalizedName") FROM stdin;
3ea1a590-7904-45de-821b-ce4183d87f5f	a0441d49-5564-455a-aca2-3a1c8332bfdc	ServerAdmin	SERVERADMIN
\.


--
-- Data for Name: AspNetUserClaims; Type: TABLE DATA; Schema: public; Owner: btcpayserver
--

COPY public."AspNetUserClaims" ("Id", "ClaimType", "ClaimValue", "UserId") FROM stdin;
\.


--
-- Data for Name: AspNetUserLogins; Type: TABLE DATA; Schema: public; Owner: btcpayserver
--

COPY public."AspNetUserLogins" ("LoginProvider", "ProviderKey", "ProviderDisplayName", "UserId") FROM stdin;
\.


--
-- Data for Name: AspNetUserRoles; Type: TABLE DATA; Schema: public; Owner: btcpayserver
--

COPY public."AspNetUserRoles" ("UserId", "RoleId") FROM stdin;
3031b3fb-7750-4f2c-9ff2-18b61e701071	3ea1a590-7904-45de-821b-ce4183d87f5f
\.


--
-- Data for Name: AspNetUserTokens; Type: TABLE DATA; Schema: public; Owner: btcpayserver
--

COPY public."AspNetUserTokens" ("UserId", "LoginProvider", "Name", "Value") FROM stdin;
\.


--
-- Data for Name: AspNetUsers; Type: TABLE DATA; Schema: public; Owner: btcpayserver
--

COPY public."AspNetUsers" ("Id", "AccessFailedCount", "ConcurrencyStamp", "Email", "EmailConfirmed", "LockoutEnabled", "LockoutEnd", "NormalizedEmail", "NormalizedUserName", "PasswordHash", "PhoneNumber", "PhoneNumberConfirmed", "SecurityStamp", "TwoFactorEnabled", "UserName", "RequiresEmailConfirmation", "Created", "DisabledNotifications", "Blob", "Blob2") FROM stdin;
3031b3fb-7750-4f2c-9ff2-18b61e701071	0	96581895-5458-4d5d-b26a-cd8a051a3253	a@a.a	f	t	\N	A@A.A	A@A.A	AQAAAAEAACcQAAAAEN3oFCaQvUlP15ily3WyIlZw4lMbl7BAdu37Fosa24ZFFj4ghNNP6Y2XWkTpgUDvaA==	\N	f	VG2XBRML5VA5EBD5M4ASS26RARTEW5MO	f	a@a.a	f	2021-11-04 15:46:07.412282+00	\N	\\x	{"showInvoiceStatusChangeHint": true}
\.


--
-- Data for Name: CustodianAccount; Type: TABLE DATA; Schema: public; Owner: btcpayserver
--

COPY public."CustodianAccount" ("Id", "StoreId", "CustodianCode", "Name", "Blob", "Blob2") FROM stdin;
\.


--
-- Data for Name: Fido2Credentials; Type: TABLE DATA; Schema: public; Owner: btcpayserver
--

COPY public."Fido2Credentials" ("Id", "Name", "ApplicationUserId", "Blob", "Type", "Blob2") FROM stdin;
\.


--
-- Data for Name: Files; Type: TABLE DATA; Schema: public; Owner: btcpayserver
--

COPY public."Files" ("Id", "FileName", "StorageFileName", "Timestamp", "ApplicationUserId") FROM stdin;
\.


--
-- Data for Name: Forms; Type: TABLE DATA; Schema: public; Owner: btcpayserver
--

COPY public."Forms" ("Id", "Name", "StoreId", "Config", "Public") FROM stdin;
\.


--
-- Data for Name: InvoiceEvents; Type: TABLE DATA; Schema: public; Owner: btcpayserver
--

COPY public."InvoiceEvents" ("InvoiceDataId", "UniqueId", "Message", "Timestamp", "Severity") FROM stdin;
\.


--
-- Data for Name: InvoiceSearches; Type: TABLE DATA; Schema: public; Owner: btcpayserver
--

COPY public."InvoiceSearches" ("Id", "InvoiceDataId", "Value") FROM stdin;
\.


--
-- Data for Name: InvoiceWebhookDeliveries; Type: TABLE DATA; Schema: public; Owner: btcpayserver
--

COPY public."InvoiceWebhookDeliveries" ("InvoiceId", "DeliveryId") FROM stdin;
\.


--
-- Data for Name: Invoices; Type: TABLE DATA; Schema: public; Owner: btcpayserver
--

COPY public."Invoices" ("Id", "Blob", "Created", "CustomerEmail", "ExceptionStatus", "ItemCode", "OrderId", "Status", "StoreDataId", "Archived", "CurrentRefundId", "Blob2") FROM stdin;
\.


--
-- Data for Name: LightningAddresses; Type: TABLE DATA; Schema: public; Owner: btcpayserver
--

COPY public."LightningAddresses" ("Username", "StoreDataId", "Blob", "Blob2") FROM stdin;
\.


--
-- Data for Name: Notifications; Type: TABLE DATA; Schema: public; Owner: btcpayserver
--

COPY public."Notifications" ("Id", "Created", "ApplicationUserId", "NotificationType", "Seen", "Blob", "Blob2") FROM stdin;
\.


--
-- Data for Name: OffchainTransactions; Type: TABLE DATA; Schema: public; Owner: btcpayserver
--

COPY public."OffchainTransactions" ("Id", "Blob") FROM stdin;
\.


--
-- Data for Name: PairedSINData; Type: TABLE DATA; Schema: public; Owner: btcpayserver
--

COPY public."PairedSINData" ("Id", "Label", "PairingTime", "SIN", "StoreDataId") FROM stdin;
\.


--
-- Data for Name: PairingCodes; Type: TABLE DATA; Schema: public; Owner: btcpayserver
--

COPY public."PairingCodes" ("Id", "DateCreated", "Expiration", "Facade", "Label", "SIN", "StoreDataId", "TokenValue") FROM stdin;
\.


--
-- Data for Name: PayjoinLocks; Type: TABLE DATA; Schema: public; Owner: btcpayserver
--

COPY public."PayjoinLocks" ("Id") FROM stdin;
\.


--
-- Data for Name: PaymentRequests; Type: TABLE DATA; Schema: public; Owner: btcpayserver
--

COPY public."PaymentRequests" ("Id", "StoreDataId", "Status", "Blob", "Created", "Archived", "Blob2") FROM stdin;
\.


--
-- Data for Name: Payments; Type: TABLE DATA; Schema: public; Owner: btcpayserver
--

COPY public."Payments" ("Id", "Blob", "InvoiceDataId", "Accounted", "Blob2", "Type") FROM stdin;
\.


--
-- Data for Name: PayoutProcessors; Type: TABLE DATA; Schema: public; Owner: btcpayserver
--

COPY public."PayoutProcessors" ("Id", "StoreId", "PaymentMethod", "Processor", "Blob", "Blob2") FROM stdin;
\.


--
-- Data for Name: Payouts; Type: TABLE DATA; Schema: public; Owner: btcpayserver
--

COPY public."Payouts" ("Id", "Date", "PullPaymentDataId", "State", "PaymentMethodId", "Destination", "Blob", "Proof", "StoreDataId") FROM stdin;
\.


--
-- Data for Name: PendingInvoices; Type: TABLE DATA; Schema: public; Owner: btcpayserver
--

COPY public."PendingInvoices" ("Id") FROM stdin;
\.


--
-- Data for Name: PlannedTransactions; Type: TABLE DATA; Schema: public; Owner: btcpayserver
--

COPY public."PlannedTransactions" ("Id", "BroadcastAt", "Blob") FROM stdin;
\.


--
-- Data for Name: PullPayments; Type: TABLE DATA; Schema: public; Owner: btcpayserver
--

COPY public."PullPayments" ("Id", "StoreId", "Period", "StartDate", "EndDate", "Archived", "Blob") FROM stdin;
\.


--
-- Data for Name: Refunds; Type: TABLE DATA; Schema: public; Owner: btcpayserver
--

COPY public."Refunds" ("InvoiceDataId", "PullPaymentDataId") FROM stdin;
\.


--
-- Data for Name: Settings; Type: TABLE DATA; Schema: public; Owner: btcpayserver
--

COPY public."Settings" ("Id", "Value") FROM stdin;
BTCPayServer.Services.ThemeSettings	{"CssUri": "/main/themes/default.css", "FirstRun": false, "CustomTheme": false, "CustomThemeCssUri": null}
BTCPayServer.Services.PoliciesSettings	{"RootAppId": null, "RootAppType": null, "LockSubscription": true, "DisableSSHService": false, "BlockExplorerLinks": [], "DomainToAppMapping": [], "CheckForNewVersions": false, "AllowHotWalletForAll": false, "RequiresConfirmedEmail": false, "DiscourageSearchEngines": false, "DisableInstantNotifications": false, "DisableNonAdminCreateUserApi": false, "AllowHotWalletRPCImportForAll": false, "AllowLightningInternalNodeForAll": false, "DisableStoresToUseServerEmailSettings": false}
BTCPayServer.Services.MigrationSettings	{"CheckedFirstRun": true, "AddStoreToPayout": true, "MigrateU2FToFIDO2": true, "AddInitialUserBlob": true, "MigrateAppYmlToJson": true, "MigrateWalletColors": true, "PaymentMethodCriteria": true, "FixMappedDomainAppType": true, "MigrateAppCustomOption": true, "ConvertMultiplierToSpread": true, "ConvertNetworkFeeProperty": true, "ConvertWalletKeyPathRoots": true, "MigrateHotwalletProperty2": true, "MigratedTransactionLabels": 2147483647, "FileSystemStorageAsDefault": true, "FixSeqAfterSqliteMigration": true, "MigratePayoutDestinationId": true, "ConvertCrowdfundOldSettings": true, "LighingAddressSettingRename": true, "MigratedInvoiceTextSearchPages": null, "LighingAddressDatabaseMigration": true, "MigrateEmailServerDisableTLSCerts": true, "TransitionToStoreBlobAdditionalData": true, "TransitionInternalNodeConnectionString": true, "DeprecatedLightningConnectionStringCheck": true}
BTCPayServer.HostedServices.RatesHostedService+ExchangeRatesCache	{"States": [], "Created": 1689088885}
BTCPayServer.Storage.Models.StorageSettings	{"Provider": 3, "ConfigurationStr": "{\\n  \\"ContainerName\\": \\"\\"\\n}"}
\.


--
-- Data for Name: StoreRoles; Type: TABLE DATA; Schema: public; Owner: btcpayserver
--

COPY public."StoreRoles" ("Id", "StoreDataId", "Role", "Permissions") FROM stdin;
Owner	\N	Owner	{btcpay.store.canmodifystoresettings,btcpay.store.cantradecustodianaccount,btcpay.store.canwithdrawfromcustodianaccount,btcpay.store.candeposittocustodianaccount}
Guest	\N	Guest	{btcpay.store.canviewstoresettings,btcpay.store.canmodifyinvoices,btcpay.store.canviewcustodianaccounts,btcpay.store.candeposittocustodianaccount}
\.


--
-- Data for Name: StoreSettings; Type: TABLE DATA; Schema: public; Owner: btcpayserver
--

COPY public."StoreSettings" ("Name", "StoreId", "Value") FROM stdin;
\.


--
-- Data for Name: StoreWebhooks; Type: TABLE DATA; Schema: public; Owner: btcpayserver
--

COPY public."StoreWebhooks" ("StoreId", "WebhookId") FROM stdin;
\.


--
-- Data for Name: Stores; Type: TABLE DATA; Schema: public; Owner: btcpayserver
--

COPY public."Stores" ("Id", "DerivationStrategy", "SpeedPolicy", "StoreCertificate", "StoreName", "StoreWebsite", "StoreBlob", "DerivationStrategies", "DefaultCrypto") FROM stdin;
9Bf5g2uHFaN21N2ub62fuNCUPrrmiyYSnT4a5iCniHCo	\N	0	\N	donations	\N	{"hints": {"wallet": false, "lightning": false}, "spread": 0.0, "cssFileId": null, "customCSS": null, "htmlTitle": null, "brandColor": null, "customLogo": null, "emailRules": null, "logoFileId": null, "rateScript": null, "defaultLang": "en", "checkoutType": "V1", "emailSettings": null, "rateScripting": false, "networkFeeMode": "Never", "payJoinEnabled": false, "receiptOptions": {"showQR": true, "enabled": true, "showPayments": true}, "defaultCurrency": "USD", "showStoreHeader": true, "storeSupportUrl": null, "anyoneCanInvoice": true, "celebratePayment": true, "paymentTolerance": 0.0, "invoiceExpiration": 15, "preferredExchange": "coingecko", "autoDetectLanguage": false, "lazyPaymentMethods": false, "showRecommendedFee": true, "requiresRefundEmail": false, "defaultCurrencyPairs": [], "monitoringExpiration": 60, "paymentMethodCriteria": [], "redirectAutomatically": false, "showPayInWalletButton": true, "displayExpirationTimer": 5, "excludedPaymentMethods": [], "lightningAmountInSatoshi": false, "recommendedFeeBlockTarget": 1, "lightningPrivateRouteHints": false, "lightningDescriptionTemplate": "Paid to {StoreName} (Order ID: {OrderId})", "onChainWithLnInvoiceFallback": false}	{"BTC": {"label": null, "source": "NBXplorerGenerated", "signingKey": "tpubDCBShd2ofpNtXwNhRTze1AcYAYF2AU1SGMMf5M9RGaCADxF93JfcWQY4PL5xUMcg2vpQ16wWG6yv1bAHsaHwt7yFPC4X4VvPAnXhXjZMJ5A", "isHotWallet": true, "accountOriginal": "tpubDCBShd2ofpNtXwNhRTze1AcYAYF2AU1SGMMf5M9RGaCADxF93JfcWQY4PL5xUMcg2vpQ16wWG6yv1bAHsaHwt7yFPC4X4VvPAnXhXjZMJ5A", "accountDerivation": "tpubDCBShd2ofpNtXwNhRTze1AcYAYF2AU1SGMMf5M9RGaCADxF93JfcWQY4PL5xUMcg2vpQ16wWG6yv1bAHsaHwt7yFPC4X4VvPAnXhXjZMJ5A", "accountKeySettings": [{"accountKey": "tpubDCBShd2ofpNtXwNhRTze1AcYAYF2AU1SGMMf5M9RGaCADxF93JfcWQY4PL5xUMcg2vpQ16wWG6yv1bAHsaHwt7yFPC4X4VvPAnXhXjZMJ5A", "accountKeyPath": "84'/1'/0'", "rootFingerprint": "83c60b64"}]}, "LBTC": {"label": null, "source": "NBXplorerGenerated", "signingKey": "tpubDDh9MBDCHM5Jx4wqNM1umSVnSbS6RrsTrj1FMLgdJExe76pKX5WTgB3MnhvxCNzWGQXiFLkeurNLJM1U5BWsTxsvfkotnJPirvGjwTRruwA", "isHotWallet": true, "accountOriginal": "tpubDDh9MBDCHM5Jx4wqNM1umSVnSbS6RrsTrj1FMLgdJExe76pKX5WTgB3MnhvxCNzWGQXiFLkeurNLJM1U5BWsTxsvfkotnJPirvGjwTRruwA", "accountDerivation": "tpubDDh9MBDCHM5Jx4wqNM1umSVnSbS6RrsTrj1FMLgdJExe76pKX5WTgB3MnhvxCNzWGQXiFLkeurNLJM1U5BWsTxsvfkotnJPirvGjwTRruwA", "accountKeySettings": [{"accountKey": "tpubDDh9MBDCHM5Jx4wqNM1umSVnSbS6RrsTrj1FMLgdJExe76pKX5WTgB3MnhvxCNzWGQXiFLkeurNLJM1U5BWsTxsvfkotnJPirvGjwTRruwA", "accountKeyPath": "84'/1'/0'", "rootFingerprint": "78098787"}]}, "BTC_LNURLPAY": {"CryptoCode": "BTC", "LUD12Enabled": false, "UseBech32Scheme": true, "EnableForStandardInvoices": true}, "BTC_LightningLike": {"CryptoCode": "BTC", "InternalNodeRef": "Internal Node", "DisableBOLT11PaymentOption": false}}	\N
\.


--
-- Data for Name: U2FDevices; Type: TABLE DATA; Schema: public; Owner: btcpayserver
--

COPY public."U2FDevices" ("Id", "Name", "KeyHandle", "PublicKey", "AttestationCert", "Counter", "ApplicationUserId") FROM stdin;
\.


--
-- Data for Name: UserStore; Type: TABLE DATA; Schema: public; Owner: btcpayserver
--

COPY public."UserStore" ("ApplicationUserId", "StoreDataId", "Role") FROM stdin;
3031b3fb-7750-4f2c-9ff2-18b61e701071	9Bf5g2uHFaN21N2ub62fuNCUPrrmiyYSnT4a5iCniHCo	Owner
\.


--
-- Data for Name: WalletObjectLinks; Type: TABLE DATA; Schema: public; Owner: btcpayserver
--

COPY public."WalletObjectLinks" ("WalletId", "AType", "AId", "BType", "BId", "Data") FROM stdin;
\.


--
-- Data for Name: WalletObjects; Type: TABLE DATA; Schema: public; Owner: btcpayserver
--

COPY public."WalletObjects" ("WalletId", "Type", "Id", "Data") FROM stdin;
\.


--
-- Data for Name: WalletTransactions; Type: TABLE DATA; Schema: public; Owner: btcpayserver
--

COPY public."WalletTransactions" ("WalletDataId", "TransactionId", "Labels", "Blob") FROM stdin;
\.


--
-- Data for Name: Wallets; Type: TABLE DATA; Schema: public; Owner: btcpayserver
--

COPY public."Wallets" ("Id", "Blob") FROM stdin;
\.


--
-- Data for Name: WebhookDeliveries; Type: TABLE DATA; Schema: public; Owner: btcpayserver
--

COPY public."WebhookDeliveries" ("Id", "WebhookId", "Timestamp", "Pruned", "Blob") FROM stdin;
\.


--
-- Data for Name: Webhooks; Type: TABLE DATA; Schema: public; Owner: btcpayserver
--

COPY public."Webhooks" ("Id", "Blob", "Blob2") FROM stdin;
\.


--
-- Data for Name: __EFMigrationsHistory; Type: TABLE DATA; Schema: public; Owner: btcpayserver
--

COPY public."__EFMigrationsHistory" ("MigrationId", "ProductVersion") FROM stdin;
20170913143004_Init	3.1.19
20170926073744_Settings	3.1.19
20170926084408_RequiresEmailConfirmation	3.1.19
20171006013443_AddressMapping	3.1.19
20171010082424_Tokens	3.1.19
20171012020112_PendingInvoices	3.1.19
20171023101754_StoreBlob	3.1.19
20171024163354_RenewUsedAddresses	3.1.19
20171105235734_PaymentAccounted	3.1.19
20171221054550_AltcoinSupport	3.1.19
20180106095215_DerivationStrategies	3.1.19
20180109021122_defaultcrypto	3.1.19
20180114123253_events	3.1.19
20180402095640_appdata	3.1.19
20180429083930_legacyapikey	3.1.19
20180719095626_CanDeleteStores	3.1.19
20190121133309_AddPaymentRequests	3.1.19
20190219032533_AppsTagging	3.1.19
20190225091644_AddOpenIddict	3.1.19
20190324141717_AddFiles	3.1.19
20190425081749_AddU2fDevices	3.1.19
20190701082105_sort_paymentrequests	3.1.19
20190802142637_WalletData	3.1.19
20200110064617_OpenIddictUpdate	3.1.19
20200119130108_ExtendApiKeys	3.1.19
20200224134444_Remove_OpenIddict	3.1.19
20200225133433_AddApiKeyLabel	3.1.19
20200402065615_AddApiKeyBlob	3.1.19
20200413052418_PlannedTransactions	3.1.19
20200507092343_AddArchivedToInvoice	3.1.19
20200625064111_refundnotificationpullpayments	3.1.19
20200901161733_AddInvoiceEventLogSeverity	3.1.19
20201002145033_AddCreateDateToUser	3.1.19
20201007090617_u2fDeviceCascade	3.1.19
20201015151438_AddDisabledNotificationsToUser	3.1.19
20201108054749_webhooks	3.1.19
20201208054211_invoicesorderindex	3.1.19
20201228225040_AddingInvoiceSearchesTable	3.1.19
20210314092253_Fido2Credentials	3.1.19
20211021085011_RemovePayoutDestinationConstraint	3.1.19
20211125081400_AddUserBlob	6.0.9
20220115184620_AddCustodianAccountData	6.0.9
20220311135252_AddPayoutProcessors	6.0.9
20220414132313_AddLightningAddress	6.0.9
20220518061525_invoice_created_idx	6.0.9
20220523022603_remove_historical_addresses	6.0.9
20220610090843_AddSettingsToStore	6.0.9
20220929132704_label	6.0.9
20221128062447_jsonb	6.0.9
20230123062447_migrateoldratesource	6.0.9
20230125085242_AddForms	6.0.9
20230130040047_blob2	6.0.9
20230130062447_jsonb2	6.0.9
20230315062447_fixmaxlength	6.0.9
20230504125505_StoreRoles	6.0.9
20230529135505_WebhookDeliveriesCleanup	6.0.9
\.


--
-- Name: InvoiceSearches_Id_seq; Type: SEQUENCE SET; Schema: public; Owner: btcpayserver
--

SELECT pg_catalog.setval('public."InvoiceSearches_Id_seq"', 1, false);


--
-- Name: AddressInvoices PK_AddressInvoices; Type: CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."AddressInvoices"
    ADD CONSTRAINT "PK_AddressInvoices" PRIMARY KEY ("Address");


--
-- Name: ApiKeys PK_ApiKeys; Type: CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."ApiKeys"
    ADD CONSTRAINT "PK_ApiKeys" PRIMARY KEY ("Id");


--
-- Name: Apps PK_Apps; Type: CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."Apps"
    ADD CONSTRAINT "PK_Apps" PRIMARY KEY ("Id");


--
-- Name: AspNetRoleClaims PK_AspNetRoleClaims; Type: CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."AspNetRoleClaims"
    ADD CONSTRAINT "PK_AspNetRoleClaims" PRIMARY KEY ("Id");


--
-- Name: AspNetRoles PK_AspNetRoles; Type: CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."AspNetRoles"
    ADD CONSTRAINT "PK_AspNetRoles" PRIMARY KEY ("Id");


--
-- Name: AspNetUserClaims PK_AspNetUserClaims; Type: CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."AspNetUserClaims"
    ADD CONSTRAINT "PK_AspNetUserClaims" PRIMARY KEY ("Id");


--
-- Name: AspNetUserLogins PK_AspNetUserLogins; Type: CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."AspNetUserLogins"
    ADD CONSTRAINT "PK_AspNetUserLogins" PRIMARY KEY ("LoginProvider", "ProviderKey");


--
-- Name: AspNetUserRoles PK_AspNetUserRoles; Type: CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."AspNetUserRoles"
    ADD CONSTRAINT "PK_AspNetUserRoles" PRIMARY KEY ("UserId", "RoleId");


--
-- Name: AspNetUserTokens PK_AspNetUserTokens; Type: CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."AspNetUserTokens"
    ADD CONSTRAINT "PK_AspNetUserTokens" PRIMARY KEY ("UserId", "LoginProvider", "Name");


--
-- Name: AspNetUsers PK_AspNetUsers; Type: CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."AspNetUsers"
    ADD CONSTRAINT "PK_AspNetUsers" PRIMARY KEY ("Id");


--
-- Name: CustodianAccount PK_CustodianAccount; Type: CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."CustodianAccount"
    ADD CONSTRAINT "PK_CustodianAccount" PRIMARY KEY ("Id");


--
-- Name: Fido2Credentials PK_Fido2Credentials; Type: CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."Fido2Credentials"
    ADD CONSTRAINT "PK_Fido2Credentials" PRIMARY KEY ("Id");


--
-- Name: Files PK_Files; Type: CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."Files"
    ADD CONSTRAINT "PK_Files" PRIMARY KEY ("Id");


--
-- Name: Forms PK_Forms; Type: CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."Forms"
    ADD CONSTRAINT "PK_Forms" PRIMARY KEY ("Id");


--
-- Name: InvoiceEvents PK_InvoiceEvents; Type: CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."InvoiceEvents"
    ADD CONSTRAINT "PK_InvoiceEvents" PRIMARY KEY ("InvoiceDataId", "UniqueId");


--
-- Name: InvoiceSearches PK_InvoiceSearches; Type: CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."InvoiceSearches"
    ADD CONSTRAINT "PK_InvoiceSearches" PRIMARY KEY ("Id");


--
-- Name: InvoiceWebhookDeliveries PK_InvoiceWebhookDeliveries; Type: CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."InvoiceWebhookDeliveries"
    ADD CONSTRAINT "PK_InvoiceWebhookDeliveries" PRIMARY KEY ("InvoiceId", "DeliveryId");


--
-- Name: Invoices PK_Invoices; Type: CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."Invoices"
    ADD CONSTRAINT "PK_Invoices" PRIMARY KEY ("Id");


--
-- Name: LightningAddresses PK_LightningAddresses; Type: CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."LightningAddresses"
    ADD CONSTRAINT "PK_LightningAddresses" PRIMARY KEY ("Username");


--
-- Name: Notifications PK_Notifications; Type: CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."Notifications"
    ADD CONSTRAINT "PK_Notifications" PRIMARY KEY ("Id");


--
-- Name: OffchainTransactions PK_OffchainTransactions; Type: CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."OffchainTransactions"
    ADD CONSTRAINT "PK_OffchainTransactions" PRIMARY KEY ("Id");


--
-- Name: PairedSINData PK_PairedSINData; Type: CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."PairedSINData"
    ADD CONSTRAINT "PK_PairedSINData" PRIMARY KEY ("Id");


--
-- Name: PairingCodes PK_PairingCodes; Type: CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."PairingCodes"
    ADD CONSTRAINT "PK_PairingCodes" PRIMARY KEY ("Id");


--
-- Name: PayjoinLocks PK_PayjoinLocks; Type: CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."PayjoinLocks"
    ADD CONSTRAINT "PK_PayjoinLocks" PRIMARY KEY ("Id");


--
-- Name: PaymentRequests PK_PaymentRequests; Type: CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."PaymentRequests"
    ADD CONSTRAINT "PK_PaymentRequests" PRIMARY KEY ("Id");


--
-- Name: Payments PK_Payments; Type: CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."Payments"
    ADD CONSTRAINT "PK_Payments" PRIMARY KEY ("Id");


--
-- Name: PayoutProcessors PK_PayoutProcessors; Type: CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."PayoutProcessors"
    ADD CONSTRAINT "PK_PayoutProcessors" PRIMARY KEY ("Id");


--
-- Name: Payouts PK_Payouts; Type: CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."Payouts"
    ADD CONSTRAINT "PK_Payouts" PRIMARY KEY ("Id");


--
-- Name: PendingInvoices PK_PendingInvoices; Type: CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."PendingInvoices"
    ADD CONSTRAINT "PK_PendingInvoices" PRIMARY KEY ("Id");


--
-- Name: PlannedTransactions PK_PlannedTransactions; Type: CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."PlannedTransactions"
    ADD CONSTRAINT "PK_PlannedTransactions" PRIMARY KEY ("Id");


--
-- Name: PullPayments PK_PullPayments; Type: CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."PullPayments"
    ADD CONSTRAINT "PK_PullPayments" PRIMARY KEY ("Id");


--
-- Name: Refunds PK_Refunds; Type: CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."Refunds"
    ADD CONSTRAINT "PK_Refunds" PRIMARY KEY ("InvoiceDataId", "PullPaymentDataId");


--
-- Name: Settings PK_Settings; Type: CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."Settings"
    ADD CONSTRAINT "PK_Settings" PRIMARY KEY ("Id");


--
-- Name: StoreRoles PK_StoreRoles; Type: CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."StoreRoles"
    ADD CONSTRAINT "PK_StoreRoles" PRIMARY KEY ("Id");


--
-- Name: StoreSettings PK_StoreSettings; Type: CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."StoreSettings"
    ADD CONSTRAINT "PK_StoreSettings" PRIMARY KEY ("StoreId", "Name");


--
-- Name: StoreWebhooks PK_StoreWebhooks; Type: CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."StoreWebhooks"
    ADD CONSTRAINT "PK_StoreWebhooks" PRIMARY KEY ("StoreId", "WebhookId");


--
-- Name: Stores PK_Stores; Type: CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."Stores"
    ADD CONSTRAINT "PK_Stores" PRIMARY KEY ("Id");


--
-- Name: U2FDevices PK_U2FDevices; Type: CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."U2FDevices"
    ADD CONSTRAINT "PK_U2FDevices" PRIMARY KEY ("Id");


--
-- Name: UserStore PK_UserStore; Type: CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."UserStore"
    ADD CONSTRAINT "PK_UserStore" PRIMARY KEY ("ApplicationUserId", "StoreDataId");


--
-- Name: WalletObjectLinks PK_WalletObjectLinks; Type: CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."WalletObjectLinks"
    ADD CONSTRAINT "PK_WalletObjectLinks" PRIMARY KEY ("WalletId", "AType", "AId", "BType", "BId");


--
-- Name: WalletObjects PK_WalletObjects; Type: CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."WalletObjects"
    ADD CONSTRAINT "PK_WalletObjects" PRIMARY KEY ("WalletId", "Type", "Id");


--
-- Name: WalletTransactions PK_WalletTransactions; Type: CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."WalletTransactions"
    ADD CONSTRAINT "PK_WalletTransactions" PRIMARY KEY ("WalletDataId", "TransactionId");


--
-- Name: Wallets PK_Wallets; Type: CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."Wallets"
    ADD CONSTRAINT "PK_Wallets" PRIMARY KEY ("Id");


--
-- Name: WebhookDeliveries PK_WebhookDeliveries; Type: CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."WebhookDeliveries"
    ADD CONSTRAINT "PK_WebhookDeliveries" PRIMARY KEY ("Id");


--
-- Name: Webhooks PK_Webhooks; Type: CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."Webhooks"
    ADD CONSTRAINT "PK_Webhooks" PRIMARY KEY ("Id");


--
-- Name: __EFMigrationsHistory PK___EFMigrationsHistory; Type: CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."__EFMigrationsHistory"
    ADD CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY ("MigrationId");


--
-- Name: EmailIndex; Type: INDEX; Schema: public; Owner: btcpayserver
--

CREATE INDEX "EmailIndex" ON public."AspNetUsers" USING btree ("NormalizedEmail");


--
-- Name: IX_AddressInvoices_InvoiceDataId; Type: INDEX; Schema: public; Owner: btcpayserver
--

CREATE INDEX "IX_AddressInvoices_InvoiceDataId" ON public."AddressInvoices" USING btree ("InvoiceDataId");


--
-- Name: IX_ApiKeys_StoreId; Type: INDEX; Schema: public; Owner: btcpayserver
--

CREATE INDEX "IX_ApiKeys_StoreId" ON public."ApiKeys" USING btree ("StoreId");


--
-- Name: IX_ApiKeys_UserId; Type: INDEX; Schema: public; Owner: btcpayserver
--

CREATE INDEX "IX_ApiKeys_UserId" ON public."ApiKeys" USING btree ("UserId");


--
-- Name: IX_Apps_StoreDataId; Type: INDEX; Schema: public; Owner: btcpayserver
--

CREATE INDEX "IX_Apps_StoreDataId" ON public."Apps" USING btree ("StoreDataId");


--
-- Name: IX_AspNetRoleClaims_RoleId; Type: INDEX; Schema: public; Owner: btcpayserver
--

CREATE INDEX "IX_AspNetRoleClaims_RoleId" ON public."AspNetRoleClaims" USING btree ("RoleId");


--
-- Name: IX_AspNetUserClaims_UserId; Type: INDEX; Schema: public; Owner: btcpayserver
--

CREATE INDEX "IX_AspNetUserClaims_UserId" ON public."AspNetUserClaims" USING btree ("UserId");


--
-- Name: IX_AspNetUserLogins_UserId; Type: INDEX; Schema: public; Owner: btcpayserver
--

CREATE INDEX "IX_AspNetUserLogins_UserId" ON public."AspNetUserLogins" USING btree ("UserId");


--
-- Name: IX_AspNetUserRoles_RoleId; Type: INDEX; Schema: public; Owner: btcpayserver
--

CREATE INDEX "IX_AspNetUserRoles_RoleId" ON public."AspNetUserRoles" USING btree ("RoleId");


--
-- Name: IX_CustodianAccount_StoreId; Type: INDEX; Schema: public; Owner: btcpayserver
--

CREATE INDEX "IX_CustodianAccount_StoreId" ON public."CustodianAccount" USING btree ("StoreId");


--
-- Name: IX_Fido2Credentials_ApplicationUserId; Type: INDEX; Schema: public; Owner: btcpayserver
--

CREATE INDEX "IX_Fido2Credentials_ApplicationUserId" ON public."Fido2Credentials" USING btree ("ApplicationUserId");


--
-- Name: IX_Files_ApplicationUserId; Type: INDEX; Schema: public; Owner: btcpayserver
--

CREATE INDEX "IX_Files_ApplicationUserId" ON public."Files" USING btree ("ApplicationUserId");


--
-- Name: IX_Forms_StoreId; Type: INDEX; Schema: public; Owner: btcpayserver
--

CREATE INDEX "IX_Forms_StoreId" ON public."Forms" USING btree ("StoreId");


--
-- Name: IX_InvoiceSearches_InvoiceDataId; Type: INDEX; Schema: public; Owner: btcpayserver
--

CREATE INDEX "IX_InvoiceSearches_InvoiceDataId" ON public."InvoiceSearches" USING btree ("InvoiceDataId");


--
-- Name: IX_InvoiceSearches_Value; Type: INDEX; Schema: public; Owner: btcpayserver
--

CREATE INDEX "IX_InvoiceSearches_Value" ON public."InvoiceSearches" USING btree ("Value");


--
-- Name: IX_Invoices_Created; Type: INDEX; Schema: public; Owner: btcpayserver
--

CREATE INDEX "IX_Invoices_Created" ON public."Invoices" USING btree ("Created");


--
-- Name: IX_Invoices_Id_CurrentRefundId; Type: INDEX; Schema: public; Owner: btcpayserver
--

CREATE INDEX "IX_Invoices_Id_CurrentRefundId" ON public."Invoices" USING btree ("Id", "CurrentRefundId");


--
-- Name: IX_Invoices_OrderId; Type: INDEX; Schema: public; Owner: btcpayserver
--

CREATE INDEX "IX_Invoices_OrderId" ON public."Invoices" USING btree ("OrderId");


--
-- Name: IX_Invoices_StoreDataId; Type: INDEX; Schema: public; Owner: btcpayserver
--

CREATE INDEX "IX_Invoices_StoreDataId" ON public."Invoices" USING btree ("StoreDataId");


--
-- Name: IX_LightningAddresses_StoreDataId; Type: INDEX; Schema: public; Owner: btcpayserver
--

CREATE INDEX "IX_LightningAddresses_StoreDataId" ON public."LightningAddresses" USING btree ("StoreDataId");


--
-- Name: IX_Notifications_ApplicationUserId; Type: INDEX; Schema: public; Owner: btcpayserver
--

CREATE INDEX "IX_Notifications_ApplicationUserId" ON public."Notifications" USING btree ("ApplicationUserId");


--
-- Name: IX_PairedSINData_SIN; Type: INDEX; Schema: public; Owner: btcpayserver
--

CREATE INDEX "IX_PairedSINData_SIN" ON public."PairedSINData" USING btree ("SIN");


--
-- Name: IX_PairedSINData_StoreDataId; Type: INDEX; Schema: public; Owner: btcpayserver
--

CREATE INDEX "IX_PairedSINData_StoreDataId" ON public."PairedSINData" USING btree ("StoreDataId");


--
-- Name: IX_PaymentRequests_Status; Type: INDEX; Schema: public; Owner: btcpayserver
--

CREATE INDEX "IX_PaymentRequests_Status" ON public."PaymentRequests" USING btree ("Status");


--
-- Name: IX_PaymentRequests_StoreDataId; Type: INDEX; Schema: public; Owner: btcpayserver
--

CREATE INDEX "IX_PaymentRequests_StoreDataId" ON public."PaymentRequests" USING btree ("StoreDataId");


--
-- Name: IX_Payments_InvoiceDataId; Type: INDEX; Schema: public; Owner: btcpayserver
--

CREATE INDEX "IX_Payments_InvoiceDataId" ON public."Payments" USING btree ("InvoiceDataId");


--
-- Name: IX_PayoutProcessors_StoreId; Type: INDEX; Schema: public; Owner: btcpayserver
--

CREATE INDEX "IX_PayoutProcessors_StoreId" ON public."PayoutProcessors" USING btree ("StoreId");


--
-- Name: IX_Payouts_Destination_State; Type: INDEX; Schema: public; Owner: btcpayserver
--

CREATE INDEX "IX_Payouts_Destination_State" ON public."Payouts" USING btree ("Destination", "State");


--
-- Name: IX_Payouts_PullPaymentDataId; Type: INDEX; Schema: public; Owner: btcpayserver
--

CREATE INDEX "IX_Payouts_PullPaymentDataId" ON public."Payouts" USING btree ("PullPaymentDataId");


--
-- Name: IX_Payouts_State; Type: INDEX; Schema: public; Owner: btcpayserver
--

CREATE INDEX "IX_Payouts_State" ON public."Payouts" USING btree ("State");


--
-- Name: IX_Payouts_StoreDataId; Type: INDEX; Schema: public; Owner: btcpayserver
--

CREATE INDEX "IX_Payouts_StoreDataId" ON public."Payouts" USING btree ("StoreDataId");


--
-- Name: IX_PullPayments_StoreId; Type: INDEX; Schema: public; Owner: btcpayserver
--

CREATE INDEX "IX_PullPayments_StoreId" ON public."PullPayments" USING btree ("StoreId");


--
-- Name: IX_Refunds_PullPaymentDataId; Type: INDEX; Schema: public; Owner: btcpayserver
--

CREATE INDEX "IX_Refunds_PullPaymentDataId" ON public."Refunds" USING btree ("PullPaymentDataId");


--
-- Name: IX_StoreRoles_StoreDataId_Role; Type: INDEX; Schema: public; Owner: btcpayserver
--

CREATE UNIQUE INDEX "IX_StoreRoles_StoreDataId_Role" ON public."StoreRoles" USING btree ("StoreDataId", "Role");


--
-- Name: IX_U2FDevices_ApplicationUserId; Type: INDEX; Schema: public; Owner: btcpayserver
--

CREATE INDEX "IX_U2FDevices_ApplicationUserId" ON public."U2FDevices" USING btree ("ApplicationUserId");


--
-- Name: IX_UserStore_StoreDataId; Type: INDEX; Schema: public; Owner: btcpayserver
--

CREATE INDEX "IX_UserStore_StoreDataId" ON public."UserStore" USING btree ("StoreDataId");


--
-- Name: IX_WalletObjectLinks_WalletId_BType_BId; Type: INDEX; Schema: public; Owner: btcpayserver
--

CREATE INDEX "IX_WalletObjectLinks_WalletId_BType_BId" ON public."WalletObjectLinks" USING btree ("WalletId", "BType", "BId");


--
-- Name: IX_WalletObjects_Type_Id; Type: INDEX; Schema: public; Owner: btcpayserver
--

CREATE INDEX "IX_WalletObjects_Type_Id" ON public."WalletObjects" USING btree ("Type", "Id");


--
-- Name: IX_WebhookDeliveries_Timestamp; Type: INDEX; Schema: public; Owner: btcpayserver
--

CREATE INDEX "IX_WebhookDeliveries_Timestamp" ON public."WebhookDeliveries" USING btree ("Timestamp") WHERE ("Pruned" IS FALSE);


--
-- Name: IX_WebhookDeliveries_WebhookId; Type: INDEX; Schema: public; Owner: btcpayserver
--

CREATE INDEX "IX_WebhookDeliveries_WebhookId" ON public."WebhookDeliveries" USING btree ("WebhookId");


--
-- Name: RoleNameIndex; Type: INDEX; Schema: public; Owner: btcpayserver
--

CREATE UNIQUE INDEX "RoleNameIndex" ON public."AspNetRoles" USING btree ("NormalizedName");


--
-- Name: UserNameIndex; Type: INDEX; Schema: public; Owner: btcpayserver
--

CREATE UNIQUE INDEX "UserNameIndex" ON public."AspNetUsers" USING btree ("NormalizedUserName");


--
-- Name: AddressInvoices FK_AddressInvoices_Invoices_InvoiceDataId; Type: FK CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."AddressInvoices"
    ADD CONSTRAINT "FK_AddressInvoices_Invoices_InvoiceDataId" FOREIGN KEY ("InvoiceDataId") REFERENCES public."Invoices"("Id") ON DELETE CASCADE;


--
-- Name: ApiKeys FK_ApiKeys_AspNetUsers_UserId; Type: FK CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."ApiKeys"
    ADD CONSTRAINT "FK_ApiKeys_AspNetUsers_UserId" FOREIGN KEY ("UserId") REFERENCES public."AspNetUsers"("Id") ON DELETE CASCADE;


--
-- Name: ApiKeys FK_ApiKeys_Stores_StoreId; Type: FK CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."ApiKeys"
    ADD CONSTRAINT "FK_ApiKeys_Stores_StoreId" FOREIGN KEY ("StoreId") REFERENCES public."Stores"("Id") ON DELETE CASCADE;


--
-- Name: Apps FK_Apps_Stores_StoreDataId; Type: FK CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."Apps"
    ADD CONSTRAINT "FK_Apps_Stores_StoreDataId" FOREIGN KEY ("StoreDataId") REFERENCES public."Stores"("Id") ON DELETE CASCADE;


--
-- Name: AspNetRoleClaims FK_AspNetRoleClaims_AspNetRoles_RoleId; Type: FK CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."AspNetRoleClaims"
    ADD CONSTRAINT "FK_AspNetRoleClaims_AspNetRoles_RoleId" FOREIGN KEY ("RoleId") REFERENCES public."AspNetRoles"("Id") ON DELETE CASCADE;


--
-- Name: AspNetUserClaims FK_AspNetUserClaims_AspNetUsers_UserId; Type: FK CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."AspNetUserClaims"
    ADD CONSTRAINT "FK_AspNetUserClaims_AspNetUsers_UserId" FOREIGN KEY ("UserId") REFERENCES public."AspNetUsers"("Id") ON DELETE CASCADE;


--
-- Name: AspNetUserLogins FK_AspNetUserLogins_AspNetUsers_UserId; Type: FK CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."AspNetUserLogins"
    ADD CONSTRAINT "FK_AspNetUserLogins_AspNetUsers_UserId" FOREIGN KEY ("UserId") REFERENCES public."AspNetUsers"("Id") ON DELETE CASCADE;


--
-- Name: AspNetUserRoles FK_AspNetUserRoles_AspNetRoles_RoleId; Type: FK CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."AspNetUserRoles"
    ADD CONSTRAINT "FK_AspNetUserRoles_AspNetRoles_RoleId" FOREIGN KEY ("RoleId") REFERENCES public."AspNetRoles"("Id") ON DELETE CASCADE;


--
-- Name: AspNetUserRoles FK_AspNetUserRoles_AspNetUsers_UserId; Type: FK CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."AspNetUserRoles"
    ADD CONSTRAINT "FK_AspNetUserRoles_AspNetUsers_UserId" FOREIGN KEY ("UserId") REFERENCES public."AspNetUsers"("Id") ON DELETE CASCADE;


--
-- Name: AspNetUserTokens FK_AspNetUserTokens_AspNetUsers_UserId; Type: FK CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."AspNetUserTokens"
    ADD CONSTRAINT "FK_AspNetUserTokens_AspNetUsers_UserId" FOREIGN KEY ("UserId") REFERENCES public."AspNetUsers"("Id") ON DELETE CASCADE;


--
-- Name: CustodianAccount FK_CustodianAccount_Stores_StoreId; Type: FK CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."CustodianAccount"
    ADD CONSTRAINT "FK_CustodianAccount_Stores_StoreId" FOREIGN KEY ("StoreId") REFERENCES public."Stores"("Id") ON DELETE CASCADE;


--
-- Name: Fido2Credentials FK_Fido2Credentials_AspNetUsers_ApplicationUserId; Type: FK CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."Fido2Credentials"
    ADD CONSTRAINT "FK_Fido2Credentials_AspNetUsers_ApplicationUserId" FOREIGN KEY ("ApplicationUserId") REFERENCES public."AspNetUsers"("Id") ON DELETE CASCADE;


--
-- Name: Files FK_Files_AspNetUsers_ApplicationUserId; Type: FK CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."Files"
    ADD CONSTRAINT "FK_Files_AspNetUsers_ApplicationUserId" FOREIGN KEY ("ApplicationUserId") REFERENCES public."AspNetUsers"("Id") ON DELETE RESTRICT;


--
-- Name: Forms FK_Forms_Stores_StoreId; Type: FK CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."Forms"
    ADD CONSTRAINT "FK_Forms_Stores_StoreId" FOREIGN KEY ("StoreId") REFERENCES public."Stores"("Id") ON DELETE CASCADE;


--
-- Name: InvoiceEvents FK_InvoiceEvents_Invoices_InvoiceDataId; Type: FK CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."InvoiceEvents"
    ADD CONSTRAINT "FK_InvoiceEvents_Invoices_InvoiceDataId" FOREIGN KEY ("InvoiceDataId") REFERENCES public."Invoices"("Id") ON DELETE CASCADE;


--
-- Name: InvoiceSearches FK_InvoiceSearches_Invoices_InvoiceDataId; Type: FK CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."InvoiceSearches"
    ADD CONSTRAINT "FK_InvoiceSearches_Invoices_InvoiceDataId" FOREIGN KEY ("InvoiceDataId") REFERENCES public."Invoices"("Id") ON DELETE CASCADE;


--
-- Name: InvoiceWebhookDeliveries FK_InvoiceWebhookDeliveries_Invoices_InvoiceId; Type: FK CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."InvoiceWebhookDeliveries"
    ADD CONSTRAINT "FK_InvoiceWebhookDeliveries_Invoices_InvoiceId" FOREIGN KEY ("InvoiceId") REFERENCES public."Invoices"("Id") ON DELETE CASCADE;


--
-- Name: InvoiceWebhookDeliveries FK_InvoiceWebhookDeliveries_WebhookDeliveries_DeliveryId; Type: FK CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."InvoiceWebhookDeliveries"
    ADD CONSTRAINT "FK_InvoiceWebhookDeliveries_WebhookDeliveries_DeliveryId" FOREIGN KEY ("DeliveryId") REFERENCES public."WebhookDeliveries"("Id") ON DELETE CASCADE;


--
-- Name: Invoices FK_Invoices_Refunds_Id_CurrentRefundId; Type: FK CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."Invoices"
    ADD CONSTRAINT "FK_Invoices_Refunds_Id_CurrentRefundId" FOREIGN KEY ("Id", "CurrentRefundId") REFERENCES public."Refunds"("InvoiceDataId", "PullPaymentDataId") ON DELETE RESTRICT;


--
-- Name: Invoices FK_Invoices_Stores_StoreDataId; Type: FK CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."Invoices"
    ADD CONSTRAINT "FK_Invoices_Stores_StoreDataId" FOREIGN KEY ("StoreDataId") REFERENCES public."Stores"("Id") ON DELETE CASCADE;


--
-- Name: LightningAddresses FK_LightningAddresses_Stores_StoreDataId; Type: FK CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."LightningAddresses"
    ADD CONSTRAINT "FK_LightningAddresses_Stores_StoreDataId" FOREIGN KEY ("StoreDataId") REFERENCES public."Stores"("Id") ON DELETE CASCADE;


--
-- Name: Notifications FK_Notifications_AspNetUsers_ApplicationUserId; Type: FK CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."Notifications"
    ADD CONSTRAINT "FK_Notifications_AspNetUsers_ApplicationUserId" FOREIGN KEY ("ApplicationUserId") REFERENCES public."AspNetUsers"("Id") ON DELETE CASCADE;


--
-- Name: PairedSINData FK_PairedSINData_Stores_StoreDataId; Type: FK CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."PairedSINData"
    ADD CONSTRAINT "FK_PairedSINData_Stores_StoreDataId" FOREIGN KEY ("StoreDataId") REFERENCES public."Stores"("Id") ON DELETE CASCADE;


--
-- Name: PaymentRequests FK_PaymentRequests_Stores_StoreDataId; Type: FK CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."PaymentRequests"
    ADD CONSTRAINT "FK_PaymentRequests_Stores_StoreDataId" FOREIGN KEY ("StoreDataId") REFERENCES public."Stores"("Id") ON DELETE CASCADE;


--
-- Name: Payments FK_Payments_Invoices_InvoiceDataId; Type: FK CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."Payments"
    ADD CONSTRAINT "FK_Payments_Invoices_InvoiceDataId" FOREIGN KEY ("InvoiceDataId") REFERENCES public."Invoices"("Id") ON DELETE CASCADE;


--
-- Name: PayoutProcessors FK_PayoutProcessors_Stores_StoreId; Type: FK CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."PayoutProcessors"
    ADD CONSTRAINT "FK_PayoutProcessors_Stores_StoreId" FOREIGN KEY ("StoreId") REFERENCES public."Stores"("Id") ON DELETE CASCADE;


--
-- Name: Payouts FK_Payouts_PullPayments_PullPaymentDataId; Type: FK CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."Payouts"
    ADD CONSTRAINT "FK_Payouts_PullPayments_PullPaymentDataId" FOREIGN KEY ("PullPaymentDataId") REFERENCES public."PullPayments"("Id") ON DELETE CASCADE;


--
-- Name: Payouts FK_Payouts_Stores_StoreDataId; Type: FK CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."Payouts"
    ADD CONSTRAINT "FK_Payouts_Stores_StoreDataId" FOREIGN KEY ("StoreDataId") REFERENCES public."Stores"("Id") ON DELETE CASCADE;


--
-- Name: PendingInvoices FK_PendingInvoices_Invoices_Id; Type: FK CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."PendingInvoices"
    ADD CONSTRAINT "FK_PendingInvoices_Invoices_Id" FOREIGN KEY ("Id") REFERENCES public."Invoices"("Id") ON DELETE CASCADE;


--
-- Name: PullPayments FK_PullPayments_Stores_StoreId; Type: FK CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."PullPayments"
    ADD CONSTRAINT "FK_PullPayments_Stores_StoreId" FOREIGN KEY ("StoreId") REFERENCES public."Stores"("Id") ON DELETE CASCADE;


--
-- Name: Refunds FK_Refunds_Invoices_InvoiceDataId; Type: FK CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."Refunds"
    ADD CONSTRAINT "FK_Refunds_Invoices_InvoiceDataId" FOREIGN KEY ("InvoiceDataId") REFERENCES public."Invoices"("Id") ON DELETE CASCADE;


--
-- Name: Refunds FK_Refunds_PullPayments_PullPaymentDataId; Type: FK CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."Refunds"
    ADD CONSTRAINT "FK_Refunds_PullPayments_PullPaymentDataId" FOREIGN KEY ("PullPaymentDataId") REFERENCES public."PullPayments"("Id") ON DELETE CASCADE;


--
-- Name: StoreRoles FK_StoreRoles_Stores_StoreDataId; Type: FK CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."StoreRoles"
    ADD CONSTRAINT "FK_StoreRoles_Stores_StoreDataId" FOREIGN KEY ("StoreDataId") REFERENCES public."Stores"("Id") ON DELETE CASCADE;


--
-- Name: StoreSettings FK_StoreSettings_Stores_StoreId; Type: FK CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."StoreSettings"
    ADD CONSTRAINT "FK_StoreSettings_Stores_StoreId" FOREIGN KEY ("StoreId") REFERENCES public."Stores"("Id") ON DELETE CASCADE;


--
-- Name: StoreWebhooks FK_StoreWebhooks_Stores_StoreId; Type: FK CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."StoreWebhooks"
    ADD CONSTRAINT "FK_StoreWebhooks_Stores_StoreId" FOREIGN KEY ("StoreId") REFERENCES public."Stores"("Id") ON DELETE CASCADE;


--
-- Name: StoreWebhooks FK_StoreWebhooks_Webhooks_WebhookId; Type: FK CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."StoreWebhooks"
    ADD CONSTRAINT "FK_StoreWebhooks_Webhooks_WebhookId" FOREIGN KEY ("WebhookId") REFERENCES public."Webhooks"("Id") ON DELETE CASCADE;


--
-- Name: U2FDevices FK_U2FDevices_AspNetUsers_ApplicationUserId; Type: FK CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."U2FDevices"
    ADD CONSTRAINT "FK_U2FDevices_AspNetUsers_ApplicationUserId" FOREIGN KEY ("ApplicationUserId") REFERENCES public."AspNetUsers"("Id") ON DELETE CASCADE;


--
-- Name: UserStore FK_UserStore_AspNetUsers_ApplicationUserId; Type: FK CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."UserStore"
    ADD CONSTRAINT "FK_UserStore_AspNetUsers_ApplicationUserId" FOREIGN KEY ("ApplicationUserId") REFERENCES public."AspNetUsers"("Id") ON DELETE CASCADE;


--
-- Name: UserStore FK_UserStore_StoreRoles_Role; Type: FK CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."UserStore"
    ADD CONSTRAINT "FK_UserStore_StoreRoles_Role" FOREIGN KEY ("Role") REFERENCES public."StoreRoles"("Id");


--
-- Name: UserStore FK_UserStore_Stores_StoreDataId; Type: FK CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."UserStore"
    ADD CONSTRAINT "FK_UserStore_Stores_StoreDataId" FOREIGN KEY ("StoreDataId") REFERENCES public."Stores"("Id") ON DELETE CASCADE;


--
-- Name: WalletObjectLinks FK_WalletObjectLinks_WalletObjects_WalletId_AType_AId; Type: FK CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."WalletObjectLinks"
    ADD CONSTRAINT "FK_WalletObjectLinks_WalletObjects_WalletId_AType_AId" FOREIGN KEY ("WalletId", "AType", "AId") REFERENCES public."WalletObjects"("WalletId", "Type", "Id") ON DELETE CASCADE;


--
-- Name: WalletObjectLinks FK_WalletObjectLinks_WalletObjects_WalletId_BType_BId; Type: FK CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."WalletObjectLinks"
    ADD CONSTRAINT "FK_WalletObjectLinks_WalletObjects_WalletId_BType_BId" FOREIGN KEY ("WalletId", "BType", "BId") REFERENCES public."WalletObjects"("WalletId", "Type", "Id") ON DELETE CASCADE;


--
-- Name: WalletTransactions FK_WalletTransactions_Wallets_WalletDataId; Type: FK CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."WalletTransactions"
    ADD CONSTRAINT "FK_WalletTransactions_Wallets_WalletDataId" FOREIGN KEY ("WalletDataId") REFERENCES public."Wallets"("Id") ON DELETE CASCADE;


--
-- Name: WebhookDeliveries FK_WebhookDeliveries_Webhooks_WebhookId; Type: FK CONSTRAINT; Schema: public; Owner: btcpayserver
--

ALTER TABLE ONLY public."WebhookDeliveries"
    ADD CONSTRAINT "FK_WebhookDeliveries_Webhooks_WebhookId" FOREIGN KEY ("WebhookId") REFERENCES public."Webhooks"("Id") ON DELETE CASCADE;


--
-- Name: DATABASE btcpaydb; Type: ACL; Schema: -; Owner: postgres
--

GRANT ALL ON DATABASE btcpaydb TO btcpayserver;


--
-- PostgreSQL database dump complete
--

