--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: action_roles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE action_roles (
    id integer NOT NULL,
    role_id bigint,
    action_id bigint,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: action_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE action_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: action_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE action_roles_id_seq OWNED BY action_roles.id;


--
-- Name: actions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE actions (
    id integer NOT NULL,
    action_name character varying(255),
    controller_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    human_name character varying(255)
);


--
-- Name: actions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: actions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE actions_id_seq OWNED BY actions.id;


--
-- Name: activities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE activities (
    id integer NOT NULL,
    outcome_id integer,
    description text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    progress character varying(255),
    index character varying(10)
);


--
-- Name: activities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE activities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: activities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE activities_id_seq OWNED BY activities.id;


--
-- Name: advisory_council_documents; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE advisory_council_documents (
    id integer NOT NULL,
    file_id character varying(255),
    filesize integer,
    original_filename character varying(255),
    revision_major integer,
    revision_minor integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    "lastModifiedDate" timestamp without time zone,
    original_type character varying(255),
    user_id integer,
    type character varying,
    date timestamp without time zone
);


--
-- Name: advisory_council_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE advisory_council_documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: advisory_council_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE advisory_council_documents_id_seq OWNED BY advisory_council_documents.id;


--
-- Name: advisory_council_issues; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE advisory_council_issues (
    id integer NOT NULL,
    file_id character varying(255),
    filesize integer,
    original_filename character varying(255),
    original_type character varying(255),
    user_id integer,
    title character varying,
    "lastModifiedDate" timestamp without time zone,
    article_link text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: advisory_council_issues_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE advisory_council_issues_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: advisory_council_issues_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE advisory_council_issues_id_seq OWNED BY advisory_council_issues.id;


--
-- Name: advisory_council_members; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE advisory_council_members (
    id integer NOT NULL,
    first_name character varying,
    last_name character varying,
    title character varying,
    organization character varying,
    department character varying,
    mobile_phone character varying,
    office_phone character varying,
    home_phone character varying,
    email character varying,
    alternate_email character varying,
    bio character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: advisory_council_members_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE advisory_council_members_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: advisory_council_members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE advisory_council_members_id_seq OWNED BY advisory_council_members.id;


--
-- Name: agencies; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE agencies (
    id integer NOT NULL,
    name character varying,
    full_name character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: agencies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE agencies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: agencies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE agencies_id_seq OWNED BY agencies.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: areas; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE areas (
    id integer NOT NULL,
    name text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: areas_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE areas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: areas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE areas_id_seq OWNED BY areas.id;


--
-- Name: assigns; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE assigns (
    id integer NOT NULL,
    complaint_id integer,
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: assigns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE assigns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: assigns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE assigns_id_seq OWNED BY assigns.id;


--
-- Name: audience_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE audience_types (
    id integer NOT NULL,
    short_type character varying,
    long_type character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: audience_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE audience_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: audience_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE audience_types_id_seq OWNED BY audience_types.id;


--
-- Name: communicants; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE communicants (
    id integer NOT NULL,
    name character varying,
    title_key character varying,
    email character varying,
    phone character varying,
    address character varying,
    organization_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: communicants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE communicants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: communicants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE communicants_id_seq OWNED BY communicants.id;


--
-- Name: communication_communicants; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE communication_communicants (
    id integer NOT NULL,
    communication_id integer,
    communicant_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: communication_communicants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE communication_communicants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: communication_communicants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE communication_communicants_id_seq OWNED BY communication_communicants.id;


--
-- Name: communication_documents; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE communication_documents (
    id integer NOT NULL,
    communication_id integer,
    file_id character varying(255),
    title character varying(255),
    filesize integer,
    filename character varying(255),
    "lastModifiedDate" timestamp without time zone,
    original_type character varying(255),
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: communication_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE communication_documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: communication_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE communication_documents_id_seq OWNED BY communication_documents.id;


--
-- Name: communications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE communications (
    id integer NOT NULL,
    complaint_id integer,
    user_id integer,
    direction character varying,
    mode character varying,
    date timestamp without time zone,
    note text
);


--
-- Name: communications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE communications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: communications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE communications_id_seq OWNED BY communications.id;


--
-- Name: complaint_agencies; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE complaint_agencies (
    id integer NOT NULL,
    complaint_id integer,
    agency_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: complaint_agencies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE complaint_agencies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: complaint_agencies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE complaint_agencies_id_seq OWNED BY complaint_agencies.id;


--
-- Name: complaint_bases; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE complaint_bases (
    id integer NOT NULL,
    name character varying,
    type character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: complaint_bases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE complaint_bases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: complaint_bases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE complaint_bases_id_seq OWNED BY complaint_bases.id;


--
-- Name: complaint_complaint_bases; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE complaint_complaint_bases (
    id integer NOT NULL,
    complaint_id integer,
    complaint_basis_id integer,
    type character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: complaint_complaint_bases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE complaint_complaint_bases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: complaint_complaint_bases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE complaint_complaint_bases_id_seq OWNED BY complaint_complaint_bases.id;


--
-- Name: complaint_conventions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE complaint_conventions (
    id integer NOT NULL,
    complaint_id integer,
    convention_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: complaint_conventions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE complaint_conventions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: complaint_conventions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE complaint_conventions_id_seq OWNED BY complaint_conventions.id;


--
-- Name: complaint_documents; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE complaint_documents (
    id integer NOT NULL,
    complaint_id integer,
    file_id character varying(255),
    title character varying(255),
    filesize integer,
    filename character varying(255),
    "lastModifiedDate" timestamp without time zone,
    original_type character varying(255),
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: complaint_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE complaint_documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: complaint_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE complaint_documents_id_seq OWNED BY complaint_documents.id;


--
-- Name: complaint_mandates; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE complaint_mandates (
    id integer NOT NULL,
    complaint_id integer,
    mandate_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: complaint_mandates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE complaint_mandates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: complaint_mandates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE complaint_mandates_id_seq OWNED BY complaint_mandates.id;


--
-- Name: complaint_statuses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE complaint_statuses (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: complaint_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE complaint_statuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: complaint_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE complaint_statuses_id_seq OWNED BY complaint_statuses.id;


--
-- Name: complaints; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE complaints (
    id integer NOT NULL,
    case_reference character varying,
    village character varying,
    phone character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    desired_outcome text,
    complained_to_subject_agency boolean,
    date_received timestamp without time zone,
    imported boolean DEFAULT false,
    mandate_id integer,
    email character varying,
    gender character varying(1),
    dob date,
    details text,
    "firstName" character varying,
    "lastName" character varying,
    chiefly_title character varying,
    occupation character varying,
    employer character varying
);


--
-- Name: complaints_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE complaints_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: complaints_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE complaints_id_seq OWNED BY complaints.id;


--
-- Name: controllers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE controllers (
    id integer NOT NULL,
    controller_name character varying(255),
    last_modified timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: controllers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE controllers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: controllers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE controllers_id_seq OWNED BY controllers.id;


--
-- Name: conventions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE conventions (
    id integer NOT NULL,
    name character varying,
    full_name character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: conventions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE conventions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: conventions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE conventions_id_seq OWNED BY conventions.id;


--
-- Name: csp_reports; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE csp_reports (
    id integer NOT NULL,
    document_uri character varying,
    referrer character varying,
    violated_directive character varying,
    effective_directive character varying,
    source_file character varying,
    original_policy text,
    blocked_uri text,
    status_code integer DEFAULT 0,
    line_number integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: csp_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE csp_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: csp_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE csp_reports_id_seq OWNED BY csp_reports.id;


--
-- Name: document_groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE document_groups (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    title character varying,
    archive_doc_count integer DEFAULT 0,
    type character varying
);


--
-- Name: document_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE document_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: document_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE document_groups_id_seq OWNED BY document_groups.id;


--
-- Name: file_monitors; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE file_monitors (
    id integer NOT NULL,
    indicator_id integer,
    user_id integer,
    "lastModifiedDate" timestamp without time zone,
    file_id character varying(255),
    filesize integer,
    original_filename character varying(255),
    original_type character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: file_monitors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE file_monitors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_monitors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE file_monitors_id_seq OWNED BY file_monitors.id;


--
-- Name: headings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE headings (
    id integer NOT NULL,
    title character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: headings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE headings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: headings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE headings_id_seq OWNED BY headings.id;


--
-- Name: human_rights_attributes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE human_rights_attributes (
    id integer NOT NULL,
    description character varying,
    heading_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: human_rights_attributes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE human_rights_attributes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: human_rights_attributes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE human_rights_attributes_id_seq OWNED BY human_rights_attributes.id;


--
-- Name: icc_reference_documents; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE icc_reference_documents (
    id integer NOT NULL,
    source_url character varying,
    title character varying,
    filesize integer,
    original_filename character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    original_type character varying(255),
    user_id integer,
    file_id character varying,
    "lastModifiedDate" timestamp without time zone
);


--
-- Name: icc_reference_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE icc_reference_documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: icc_reference_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE icc_reference_documents_id_seq OWNED BY icc_reference_documents.id;


--
-- Name: indicators; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE indicators (
    id integer NOT NULL,
    title character varying,
    human_rights_attribute_id integer,
    heading_id integer,
    nature character varying,
    monitor_format character varying,
    numeric_monitor_explanation character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: indicators_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE indicators_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: indicators_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE indicators_id_seq OWNED BY indicators.id;


--
-- Name: internal_documents; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE internal_documents (
    id integer NOT NULL,
    file_id character varying(255),
    title character varying(255),
    filesize integer,
    original_filename character varying(255),
    revision_major integer,
    revision_minor integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    "lastModifiedDate" timestamp without time zone,
    original_type character varying(255),
    document_group_id integer,
    user_id integer,
    type character varying
);


--
-- Name: internal_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE internal_documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: internal_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE internal_documents_id_seq OWNED BY internal_documents.id;


--
-- Name: issue_areas; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE issue_areas (
    id integer NOT NULL,
    advisory_council_issue_id integer,
    area_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: issue_areas_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE issue_areas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: issue_areas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE issue_areas_id_seq OWNED BY issue_areas.id;


--
-- Name: issue_subareas; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE issue_subareas (
    id integer NOT NULL,
    advisory_council_issue_id integer,
    subarea_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: issue_subareas_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE issue_subareas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: issue_subareas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE issue_subareas_id_seq OWNED BY issue_subareas.id;


--
-- Name: mandates; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE mandates (
    id integer NOT NULL,
    key character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: mandates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE mandates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mandates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE mandates_id_seq OWNED BY mandates.id;


--
-- Name: media_appearance_performance_indicators; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE media_appearance_performance_indicators (
    id integer NOT NULL,
    media_appearance_id integer,
    performance_indicator_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: media_appearance_performance_indicators_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE media_appearance_performance_indicators_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: media_appearance_performance_indicators_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE media_appearance_performance_indicators_id_seq OWNED BY media_appearance_performance_indicators.id;


--
-- Name: media_appearances; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE media_appearances (
    id integer NOT NULL,
    file_id character varying(255),
    filesize integer,
    original_filename character varying(255),
    original_type character varying(255),
    user_id integer,
    url character varying,
    title character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    "lastModifiedDate" timestamp without time zone,
    article_link text
);


--
-- Name: media_appearances_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE media_appearances_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: media_appearances_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE media_appearances_id_seq OWNED BY media_appearances.id;


--
-- Name: media_areas; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE media_areas (
    id integer NOT NULL,
    media_appearance_id integer,
    area_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: media_areas_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE media_areas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: media_areas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE media_areas_id_seq OWNED BY media_areas.id;


--
-- Name: media_subareas; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE media_subareas (
    id integer NOT NULL,
    media_appearance_id integer,
    subarea_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: media_subareas_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE media_subareas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: media_subareas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE media_subareas_id_seq OWNED BY media_subareas.id;


--
-- Name: notes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE notes (
    id integer NOT NULL,
    text text,
    notable_id integer,
    author_id integer,
    editor_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    notable_type character varying
);


--
-- Name: notes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE notes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE notes_id_seq OWNED BY notes.id;


--
-- Name: numeric_monitors; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE numeric_monitors (
    id integer NOT NULL,
    indicator_id integer,
    author_id integer,
    date timestamp without time zone,
    value integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: numeric_monitors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE numeric_monitors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: numeric_monitors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE numeric_monitors_id_seq OWNED BY numeric_monitors.id;


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE organizations (
    id integer NOT NULL,
    name character varying(255),
    street character varying(255),
    city character varying(255),
    zip character varying(255),
    phone character varying(255),
    email character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    contacts character varying(255),
    state character varying(255)
);


--
-- Name: organizations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE organizations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE organizations_id_seq OWNED BY organizations.id;


--
-- Name: outcomes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE outcomes (
    id integer NOT NULL,
    planned_result_id integer,
    description text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    index character varying(10)
);


--
-- Name: outcomes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE outcomes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: outcomes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE outcomes_id_seq OWNED BY outcomes.id;


--
-- Name: performance_indicators; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE performance_indicators (
    id integer NOT NULL,
    activity_id integer,
    description text,
    target text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    index character varying(10)
);


--
-- Name: performance_indicators_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE performance_indicators_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: performance_indicators_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE performance_indicators_id_seq OWNED BY performance_indicators.id;


--
-- Name: planned_results; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE planned_results (
    id integer NOT NULL,
    description character varying(255),
    strategic_priority_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    index character varying(10)
);


--
-- Name: planned_results_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE planned_results_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: planned_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE planned_results_id_seq OWNED BY planned_results.id;


--
-- Name: project_documents; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE project_documents (
    id integer NOT NULL,
    project_id integer,
    file_id character varying(255),
    title character varying(255),
    filesize integer,
    filename character varying(255),
    "lastModifiedDate" timestamp without time zone,
    original_type character varying(255),
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: project_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE project_documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE project_documents_id_seq OWNED BY project_documents.id;


--
-- Name: project_mandates; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE project_mandates (
    id integer NOT NULL,
    project_id integer,
    mandate_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: project_mandates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE project_mandates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_mandates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE project_mandates_id_seq OWNED BY project_mandates.id;


--
-- Name: project_named_documents; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE project_named_documents (
    id integer NOT NULL
);


--
-- Name: project_named_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE project_named_documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_named_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE project_named_documents_id_seq OWNED BY project_named_documents.id;


--
-- Name: project_performance_indicators; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE project_performance_indicators (
    id integer NOT NULL,
    project_id integer,
    performance_indicator_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: project_performance_indicators_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE project_performance_indicators_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_performance_indicators_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE project_performance_indicators_id_seq OWNED BY project_performance_indicators.id;


--
-- Name: project_project_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE project_project_types (
    id integer NOT NULL,
    project_id integer,
    project_type_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: project_project_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE project_project_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_project_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE project_project_types_id_seq OWNED BY project_project_types.id;


--
-- Name: project_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE project_types (
    id integer NOT NULL,
    name character varying,
    mandate_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: project_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE project_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE project_types_id_seq OWNED BY project_types.id;


--
-- Name: projects; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE projects (
    id integer NOT NULL,
    title character varying,
    description text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE projects_id_seq OWNED BY projects.id;


--
-- Name: reminders; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE reminders (
    id integer NOT NULL,
    text character varying(255),
    reminder_type character varying(255),
    remindable_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    remindable_type character varying,
    start_date timestamp without time zone,
    next timestamp without time zone,
    user_id integer
);


--
-- Name: reminders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE reminders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reminders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE reminders_id_seq OWNED BY reminders.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE roles (
    id integer NOT NULL,
    name character varying(255),
    short_name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    parent_id integer
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE roles_id_seq OWNED BY roles.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sessions (
    id integer NOT NULL,
    user_id integer,
    session_id character varying(255),
    login_date timestamp without time zone,
    logout_date timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    expired boolean DEFAULT false
);


--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sessions_id_seq OWNED BY sessions.id;


--
-- Name: settings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE settings (
    id integer NOT NULL,
    var character varying(255) NOT NULL,
    value text,
    thing_id integer,
    thing_type character varying(30),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE settings_id_seq OWNED BY settings.id;


--
-- Name: status_changes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE status_changes (
    id integer NOT NULL,
    complaint_id integer,
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    complaint_status_id integer,
    change_date timestamp without time zone
);


--
-- Name: status_changes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE status_changes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: status_changes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE status_changes_id_seq OWNED BY status_changes.id;


--
-- Name: strategic_plans; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE strategic_plans (
    id integer NOT NULL,
    start_date date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    title character varying
);


--
-- Name: strategic_plans_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE strategic_plans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: strategic_plans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE strategic_plans_id_seq OWNED BY strategic_plans.id;


--
-- Name: strategic_priorities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE strategic_priorities (
    id integer NOT NULL,
    priority_level integer,
    description text,
    strategic_plan_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: strategic_priorities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE strategic_priorities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: strategic_priorities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE strategic_priorities_id_seq OWNED BY strategic_priorities.id;


--
-- Name: subareas; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE subareas (
    id integer NOT NULL,
    name text,
    full_name text,
    area_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: subareas_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE subareas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subareas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE subareas_id_seq OWNED BY subareas.id;


--
-- Name: text_monitors; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE text_monitors (
    id integer NOT NULL,
    indicator_id integer,
    author_id integer,
    date timestamp without time zone,
    description character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: text_monitors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE text_monitors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: text_monitors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE text_monitors_id_seq OWNED BY text_monitors.id;


--
-- Name: user_roles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_roles (
    id integer NOT NULL,
    role_id bigint NOT NULL,
    user_id bigint NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: user_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_roles_id_seq OWNED BY user_roles.id;


--
-- Name: useractions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE useractions (
    id integer NOT NULL,
    user_id integer,
    action_id integer,
    type character varying(255),
    params text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: useractions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE useractions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: useractions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE useractions_id_seq OWNED BY useractions.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    login character varying(255),
    email character varying(255),
    crypted_password character varying(40),
    salt character varying(40),
    activation_code character varying(40),
    activated_at timestamp without time zone,
    password_reset_code character varying(40),
    enabled boolean DEFAULT true,
    "firstName" character varying(255),
    "lastName" character varying(255),
    type character varying(255),
    status character varying(255) DEFAULT 'created'::character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    organization_id integer,
    challenge character varying,
    challenge_timestamp timestamp without time zone,
    public_key character varying,
    public_key_handle character varying,
    replacement_token_registration_code character varying
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY action_roles ALTER COLUMN id SET DEFAULT nextval('action_roles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY actions ALTER COLUMN id SET DEFAULT nextval('actions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY activities ALTER COLUMN id SET DEFAULT nextval('activities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY advisory_council_documents ALTER COLUMN id SET DEFAULT nextval('advisory_council_documents_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY advisory_council_issues ALTER COLUMN id SET DEFAULT nextval('advisory_council_issues_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY advisory_council_members ALTER COLUMN id SET DEFAULT nextval('advisory_council_members_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY agencies ALTER COLUMN id SET DEFAULT nextval('agencies_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY areas ALTER COLUMN id SET DEFAULT nextval('areas_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY assigns ALTER COLUMN id SET DEFAULT nextval('assigns_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY audience_types ALTER COLUMN id SET DEFAULT nextval('audience_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY communicants ALTER COLUMN id SET DEFAULT nextval('communicants_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY communication_communicants ALTER COLUMN id SET DEFAULT nextval('communication_communicants_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY communication_documents ALTER COLUMN id SET DEFAULT nextval('communication_documents_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY communications ALTER COLUMN id SET DEFAULT nextval('communications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY complaint_agencies ALTER COLUMN id SET DEFAULT nextval('complaint_agencies_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY complaint_bases ALTER COLUMN id SET DEFAULT nextval('complaint_bases_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY complaint_complaint_bases ALTER COLUMN id SET DEFAULT nextval('complaint_complaint_bases_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY complaint_conventions ALTER COLUMN id SET DEFAULT nextval('complaint_conventions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY complaint_documents ALTER COLUMN id SET DEFAULT nextval('complaint_documents_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY complaint_mandates ALTER COLUMN id SET DEFAULT nextval('complaint_mandates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY complaint_statuses ALTER COLUMN id SET DEFAULT nextval('complaint_statuses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY complaints ALTER COLUMN id SET DEFAULT nextval('complaints_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY controllers ALTER COLUMN id SET DEFAULT nextval('controllers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY conventions ALTER COLUMN id SET DEFAULT nextval('conventions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY csp_reports ALTER COLUMN id SET DEFAULT nextval('csp_reports_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY document_groups ALTER COLUMN id SET DEFAULT nextval('document_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_monitors ALTER COLUMN id SET DEFAULT nextval('file_monitors_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY headings ALTER COLUMN id SET DEFAULT nextval('headings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY human_rights_attributes ALTER COLUMN id SET DEFAULT nextval('human_rights_attributes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY icc_reference_documents ALTER COLUMN id SET DEFAULT nextval('icc_reference_documents_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY indicators ALTER COLUMN id SET DEFAULT nextval('indicators_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY internal_documents ALTER COLUMN id SET DEFAULT nextval('internal_documents_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY issue_areas ALTER COLUMN id SET DEFAULT nextval('issue_areas_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY issue_subareas ALTER COLUMN id SET DEFAULT nextval('issue_subareas_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY mandates ALTER COLUMN id SET DEFAULT nextval('mandates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_appearance_performance_indicators ALTER COLUMN id SET DEFAULT nextval('media_appearance_performance_indicators_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_appearances ALTER COLUMN id SET DEFAULT nextval('media_appearances_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_areas ALTER COLUMN id SET DEFAULT nextval('media_areas_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_subareas ALTER COLUMN id SET DEFAULT nextval('media_subareas_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY notes ALTER COLUMN id SET DEFAULT nextval('notes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY numeric_monitors ALTER COLUMN id SET DEFAULT nextval('numeric_monitors_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY organizations ALTER COLUMN id SET DEFAULT nextval('organizations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY outcomes ALTER COLUMN id SET DEFAULT nextval('outcomes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY performance_indicators ALTER COLUMN id SET DEFAULT nextval('performance_indicators_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY planned_results ALTER COLUMN id SET DEFAULT nextval('planned_results_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_documents ALTER COLUMN id SET DEFAULT nextval('project_documents_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_mandates ALTER COLUMN id SET DEFAULT nextval('project_mandates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_named_documents ALTER COLUMN id SET DEFAULT nextval('project_named_documents_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_performance_indicators ALTER COLUMN id SET DEFAULT nextval('project_performance_indicators_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_project_types ALTER COLUMN id SET DEFAULT nextval('project_project_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_types ALTER COLUMN id SET DEFAULT nextval('project_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects ALTER COLUMN id SET DEFAULT nextval('projects_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY reminders ALTER COLUMN id SET DEFAULT nextval('reminders_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY roles ALTER COLUMN id SET DEFAULT nextval('roles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sessions ALTER COLUMN id SET DEFAULT nextval('sessions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY settings ALTER COLUMN id SET DEFAULT nextval('settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY status_changes ALTER COLUMN id SET DEFAULT nextval('status_changes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY strategic_plans ALTER COLUMN id SET DEFAULT nextval('strategic_plans_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY strategic_priorities ALTER COLUMN id SET DEFAULT nextval('strategic_priorities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY subareas ALTER COLUMN id SET DEFAULT nextval('subareas_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY text_monitors ALTER COLUMN id SET DEFAULT nextval('text_monitors_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_roles ALTER COLUMN id SET DEFAULT nextval('user_roles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY useractions ALTER COLUMN id SET DEFAULT nextval('useractions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: action_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY action_roles
    ADD CONSTRAINT action_roles_pkey PRIMARY KEY (id);


--
-- Name: actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY actions
    ADD CONSTRAINT actions_pkey PRIMARY KEY (id);


--
-- Name: activities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY activities
    ADD CONSTRAINT activities_pkey PRIMARY KEY (id);


--
-- Name: advisory_council_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY advisory_council_documents
    ADD CONSTRAINT advisory_council_documents_pkey PRIMARY KEY (id);


--
-- Name: advisory_council_issues_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY advisory_council_issues
    ADD CONSTRAINT advisory_council_issues_pkey PRIMARY KEY (id);


--
-- Name: advisory_council_members_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY advisory_council_members
    ADD CONSTRAINT advisory_council_members_pkey PRIMARY KEY (id);


--
-- Name: agencies_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY agencies
    ADD CONSTRAINT agencies_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: areas_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY areas
    ADD CONSTRAINT areas_pkey PRIMARY KEY (id);


--
-- Name: assigns_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY assigns
    ADD CONSTRAINT assigns_pkey PRIMARY KEY (id);


--
-- Name: audience_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY audience_types
    ADD CONSTRAINT audience_types_pkey PRIMARY KEY (id);


--
-- Name: communicants_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY communicants
    ADD CONSTRAINT communicants_pkey PRIMARY KEY (id);


--
-- Name: communication_communicants_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY communication_communicants
    ADD CONSTRAINT communication_communicants_pkey PRIMARY KEY (id);


--
-- Name: communication_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY communication_documents
    ADD CONSTRAINT communication_documents_pkey PRIMARY KEY (id);


--
-- Name: communications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY communications
    ADD CONSTRAINT communications_pkey PRIMARY KEY (id);


--
-- Name: complaint_agencies_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY complaint_agencies
    ADD CONSTRAINT complaint_agencies_pkey PRIMARY KEY (id);


--
-- Name: complaint_bases_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY complaint_bases
    ADD CONSTRAINT complaint_bases_pkey PRIMARY KEY (id);


--
-- Name: complaint_complaint_bases_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY complaint_complaint_bases
    ADD CONSTRAINT complaint_complaint_bases_pkey PRIMARY KEY (id);


--
-- Name: complaint_conventions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY complaint_conventions
    ADD CONSTRAINT complaint_conventions_pkey PRIMARY KEY (id);


--
-- Name: complaint_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY complaint_documents
    ADD CONSTRAINT complaint_documents_pkey PRIMARY KEY (id);


--
-- Name: complaint_mandates_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY complaint_mandates
    ADD CONSTRAINT complaint_mandates_pkey PRIMARY KEY (id);


--
-- Name: complaint_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY complaint_statuses
    ADD CONSTRAINT complaint_statuses_pkey PRIMARY KEY (id);


--
-- Name: complaints_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY complaints
    ADD CONSTRAINT complaints_pkey PRIMARY KEY (id);


--
-- Name: controllers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY controllers
    ADD CONSTRAINT controllers_pkey PRIMARY KEY (id);


--
-- Name: conventions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY conventions
    ADD CONSTRAINT conventions_pkey PRIMARY KEY (id);


--
-- Name: csp_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY csp_reports
    ADD CONSTRAINT csp_reports_pkey PRIMARY KEY (id);


--
-- Name: document_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY document_groups
    ADD CONSTRAINT document_groups_pkey PRIMARY KEY (id);


--
-- Name: file_monitors_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY file_monitors
    ADD CONSTRAINT file_monitors_pkey PRIMARY KEY (id);


--
-- Name: headings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY headings
    ADD CONSTRAINT headings_pkey PRIMARY KEY (id);


--
-- Name: human_rights_attributes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY human_rights_attributes
    ADD CONSTRAINT human_rights_attributes_pkey PRIMARY KEY (id);


--
-- Name: icc_reference_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY icc_reference_documents
    ADD CONSTRAINT icc_reference_documents_pkey PRIMARY KEY (id);


--
-- Name: indicators_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY indicators
    ADD CONSTRAINT indicators_pkey PRIMARY KEY (id);


--
-- Name: internal_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY internal_documents
    ADD CONSTRAINT internal_documents_pkey PRIMARY KEY (id);


--
-- Name: issue_areas_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY issue_areas
    ADD CONSTRAINT issue_areas_pkey PRIMARY KEY (id);


--
-- Name: issue_subareas_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY issue_subareas
    ADD CONSTRAINT issue_subareas_pkey PRIMARY KEY (id);


--
-- Name: mandates_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mandates
    ADD CONSTRAINT mandates_pkey PRIMARY KEY (id);


--
-- Name: media_appearance_performance_indicators_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY media_appearance_performance_indicators
    ADD CONSTRAINT media_appearance_performance_indicators_pkey PRIMARY KEY (id);


--
-- Name: media_appearances_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY media_appearances
    ADD CONSTRAINT media_appearances_pkey PRIMARY KEY (id);


--
-- Name: media_areas_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY media_areas
    ADD CONSTRAINT media_areas_pkey PRIMARY KEY (id);


--
-- Name: media_subareas_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY media_subareas
    ADD CONSTRAINT media_subareas_pkey PRIMARY KEY (id);


--
-- Name: notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY notes
    ADD CONSTRAINT notes_pkey PRIMARY KEY (id);


--
-- Name: numeric_monitors_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY numeric_monitors
    ADD CONSTRAINT numeric_monitors_pkey PRIMARY KEY (id);


--
-- Name: organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: outcomes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY outcomes
    ADD CONSTRAINT outcomes_pkey PRIMARY KEY (id);


--
-- Name: performance_indicators_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY performance_indicators
    ADD CONSTRAINT performance_indicators_pkey PRIMARY KEY (id);


--
-- Name: planned_results_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY planned_results
    ADD CONSTRAINT planned_results_pkey PRIMARY KEY (id);


--
-- Name: project_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY project_documents
    ADD CONSTRAINT project_documents_pkey PRIMARY KEY (id);


--
-- Name: project_mandates_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY project_mandates
    ADD CONSTRAINT project_mandates_pkey PRIMARY KEY (id);


--
-- Name: project_named_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY project_named_documents
    ADD CONSTRAINT project_named_documents_pkey PRIMARY KEY (id);


--
-- Name: project_performance_indicators_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY project_performance_indicators
    ADD CONSTRAINT project_performance_indicators_pkey PRIMARY KEY (id);


--
-- Name: project_project_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY project_project_types
    ADD CONSTRAINT project_project_types_pkey PRIMARY KEY (id);


--
-- Name: project_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY project_types
    ADD CONSTRAINT project_types_pkey PRIMARY KEY (id);


--
-- Name: projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: reminders_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reminders
    ADD CONSTRAINT reminders_pkey PRIMARY KEY (id);


--
-- Name: roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: status_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY status_changes
    ADD CONSTRAINT status_changes_pkey PRIMARY KEY (id);


--
-- Name: strategic_plans_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY strategic_plans
    ADD CONSTRAINT strategic_plans_pkey PRIMARY KEY (id);


--
-- Name: strategic_priorities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY strategic_priorities
    ADD CONSTRAINT strategic_priorities_pkey PRIMARY KEY (id);


--
-- Name: subareas_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY subareas
    ADD CONSTRAINT subareas_pkey PRIMARY KEY (id);


--
-- Name: text_monitors_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY text_monitors
    ADD CONSTRAINT text_monitors_pkey PRIMARY KEY (id);


--
-- Name: user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (id);


--
-- Name: useractions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY useractions
    ADD CONSTRAINT useractions_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_actions_on_action_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_actions_on_action_name ON actions USING btree (action_name);


--
-- Name: index_controllers_on_controller_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_controllers_on_controller_name ON controllers USING btree (controller_name);


--
-- Name: index_sessions_on_session_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sessions_on_session_id ON sessions USING btree (session_id);


--
-- Name: index_settings_on_thing_type_and_thing_id_and_var; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_settings_on_thing_type_and_thing_id_and_var ON settings USING btree (thing_type, thing_id, var);


--
-- Name: index_users_on_login; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_login ON users USING btree (login);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES
('20150312211029'),
('20150319164500'),
('20150331213630'),
('20150401173232'),
('20150401203024'),
('20150405214438'),
('20150413132718'),
('20150413132818'),
('20150414194301'),
('20150421130050'),
('20150502200245'),
('20150502200620'),
('20150522034635'),
('20150525132045'),
('20150525165705'),
('20150605025933'),
('20150606044219'),
('20150619133134'),
('20150710184108'),
('20150727195735'),
('20150730210700'),
('20150804030751'),
('20150804030912'),
('20150818135907'),
('20150823224746'),
('20150823240000'),
('20150824035832'),
('20150824043913'),
('20150906205933'),
('20150907125812'),
('20150909064600'),
('20150920024842'),
('20150926041351'),
('20150928155418'),
('20150928155803'),
('20151107034103'),
('20151107045617'),
('20151115003736'),
('20151130044838'),
('20151203025435'),
('20151207033945'),
('20151221005515'),
('20160112235437'),
('20160113225036'),
('20160113225056'),
('20160117015413'),
('20160117020145'),
('20160120210924'),
('20160124053548'),
('20160205195334'),
('20160211135339'),
('20160215043218'),
('20160215222701'),
('20160217003133'),
('20160221164038'),
('20160224184153'),
('20160228174227'),
('20160229173934'),
('20160301185412'),
('20160308041416'),
('20160408210221'),
('20160408234207'),
('20160409220837'),
('20160508035237'),
('20160508035249'),
('20160521010000'),
('20160527155228'),
('20160601131916'),
('20160603143022'),
('20160619191444'),
('20160701043358'),
('20160716211805'),
('20160801013012'),
('20160805122035'),
('20160819032747'),
('20160903035120'),
('20160903035238'),
('20160915141929'),
('20160921143002'),
('20160929133652'),
('20161031195034'),
('20161031205855'),
('20161102171623'),
('20161103003047'),
('20161103015105'),
('20161103072654'),
('20161106195127'),
('20161106231332'),
('20161121173100'),
('20161211034030'),
('20161214171824'),
('20161227005750'),
('20161230204509'),
('20161231185559'),
('20170119041053'),
('20170307170424'),
('20170321165122'),
('20170324131512'),
('20170324131534'),
('20170330155442'),
('20170330160237'),
('20170330161242'),
('20170401002304'),
('20170401003007'),
('20170411155901');


