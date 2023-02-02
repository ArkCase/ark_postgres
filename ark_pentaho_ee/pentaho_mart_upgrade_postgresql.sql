-- Pentaho Monitoring Datamart

-- Upgrades from 4.4.0 to next release

drop index if exists IDX_DIM_EXECUTION_LOOKUP;

alter table pdi_operations_mart.dim_execution drop column server_name;

alter table pdi_operations_mart.dim_execution add column client varchar(255) DEFAULT NULL;

CREATE INDEX IDX_DIM_EXECUTION_LOOKUP ON pdi_operations_mart.DIM_EXECUTION(execution_id,server_host,executing_user,client);

alter table pdi_operations_mart.fact_execution add column failed smallint DEFAULT 0;

update pdi_operations_mart.fact_execution set failed = (case when errors > 0 then 1 else 0 end);

CREATE TABLE  pentaho_operations_mart.DIM_STATE (
  state_tk bigint NOT NULL,
  state varchar(100) NOT NULL,
  PRIMARY KEY (state_tk)  
);
CREATE INDEX IDX_DIM_STATE_STATE_TK ON pentaho_operations_mart.DIM_STATE (state_tk);

CREATE TABLE  pentaho_operations_mart.DIM_SESSION (
  session_tk bigint NOT NULL,
  session_id varchar(200) NOT NULL,
  session_type varchar(200) NOT NULL,
  username varchar(200) NOT NULL,
  PRIMARY KEY (session_tk)  
);
CREATE INDEX IDX_DIM_SESSION_SESSION_TK ON pentaho_operations_mart.DIM_SESSION (session_tk);

CREATE TABLE  pentaho_operations_mart.DIM_INSTANCE (
  instance_tk bigint NOT NULL,
  instance_id varchar(200) NOT NULL,
  engine_id varchar(200) NOT NULL,
  service_id varchar(200) NOT NULL,
  content_id varchar(1024) NOT NULL,
  content_detail varchar(1024) NOT NULL,
  PRIMARY KEY (instance_tk)  
);
CREATE INDEX IDX_DIM_INSTANCE_INSTANCE_TK ON pentaho_operations_mart.DIM_INSTANCE (instance_tk);

CREATE TABLE  pentaho_operations_mart.DIM_COMPONENT (
  component_tk bigint NOT NULL,
  component_id varchar(200) NOT NULL,
  PRIMARY KEY (component_tk)  
);
CREATE INDEX IDX_DIM_COMPONENT_COMPONENT_TK ON pentaho_operations_mart.DIM_COMPONENT (component_tk);

CREATE TABLE pentaho_operations_mart.STG_CONTENT_ITEM (
  gid char(36) NOT NULL,
  parent_gid char(36) DEFAULT NULL,
  fileSize int NOT NULL,
  locale varchar(5) DEFAULT NULL,
  name varchar(200) NOT NULL,
  ownerType int NOT NULL,
  path varchar(1024) NOT NULL,
  title varchar(255) DEFAULT NULL,
  is_folder char(1) NOT NULL,
  is_hidden char(1) NOT NULL,
  is_locked char(1) NOT NULL,
  is_versioned char(1) NOT NULL,
  date_created timestamp DEFAULT NULL,
  date_last_modified timestamp DEFAULT NULL,
  is_processed char(1) DEFAULT NULL,
  PRIMARY KEY (gid)
);
CREATE INDEX IDX_STG_CONTENT_ITEM_GID ON pentaho_operations_mart.STG_CONTENT_ITEM (gid);

CREATE TABLE pentaho_operations_mart.DIM_CONTENT_ITEM (
  content_item_tk int NOT NULL,
  content_item_title VARCHAR(255) NOT NULL DEFAULT 'NA',
  content_item_locale VARCHAR(255) NOT NULL DEFAULT 'NA',
  content_item_size int NULL DEFAULT 0,
  content_item_path VARCHAR(1024) NULL DEFAULT 'NA',
  content_item_name VARCHAR(255) NOT NULL DEFAULT 'NA',
  content_item_fullname VARCHAR(1024) NOT NULL DEFAULT 'NA',
  content_item_type VARCHAR(32) NOT NULL DEFAULT 'NA',
  content_item_extension VARCHAR(32) NULL DEFAULT 'NA',
  content_item_guid CHAR(36) NOT NULL DEFAULT 'NA',
  parent_content_item_guid CHAR(36) NULL DEFAULT 'NA',
  parent_content_item_tk int NULL,
  content_item_modified timestamp NOT NULL DEFAULT '1900-01-01 00:00:00',
  content_item_valid_from timestamp NOT NULL DEFAULT '1900-01-01 00:00:00',
  content_item_valid_to timestamp NOT NULL DEFAULT '9999-12-31 23:59:59',
  content_item_state VARCHAR(16) NULL DEFAULT 'new',
  content_item_version int NOT NULL DEFAULT 0,
  PRIMARY KEY(content_item_tk)
);
CREATE INDEX IDX_DIM_CONTENT_ITEM_CONTENT_ITEM_TK ON pentaho_operations_mart.DIM_CONTENT_ITEM (content_item_tk);
CREATE INDEX IDX_DIM_CONTENT_ITEM_GUID_FROM ON pentaho_operations_mart.DIM_CONTENT_ITEM (content_item_guid, content_item_valid_from);

CREATE TABLE  pentaho_operations_mart.FACT_SESSION (
  start_date_tk int NOT NULL,
  start_time_tk int NOT NULL,
  end_date_tk int NOT NULL,
  end_time_tk int NOT NULL,
  session_tk bigint NOT NULL,
  state_tk bigint NOT NULL,
  duration numeric(19,3) NOT NULL
);
CREATE INDEX IDX_FACT_PERF_SESSION_START_DATE_TK ON pentaho_operations_mart.FACT_SESSION(start_date_tk);
CREATE INDEX IDX_FACT_PERF_SESSION_START_TIME_TK ON pentaho_operations_mart.FACT_SESSION(start_time_tk);
CREATE INDEX IDX_FACT_PERF_SESSION_END_DATE_TK ON pentaho_operations_mart.FACT_SESSION(end_date_tk);
CREATE INDEX IDX_FACT_PERF_SESSION_END_TIME_TK ON pentaho_operations_mart.FACT_SESSION(end_time_tk);
CREATE INDEX IDX_FACT_PERF_SESSION_SESSION_TK ON pentaho_operations_mart.FACT_SESSION(session_tk);
CREATE INDEX IDX_FACT_PERF_SESSION_STATE_TK ON pentaho_operations_mart.FACT_SESSION(state_tk);

CREATE TABLE  pentaho_operations_mart.FACT_INSTANCE (
  start_date_tk int NOT NULL,
  start_time_tk int NOT NULL,
  end_date_tk int NOT NULL,
  end_time_tk int NOT NULL,
  session_tk bigint NOT NULL,
  instance_tk bigint NOT NULL,
  state_tk bigint NOT NULL,
  duration numeric(19,3) NOT NULL
);
CREATE INDEX IDX_FACT_PERF_INSTANCE_START_DATE_TK ON pentaho_operations_mart.FACT_INSTANCE(start_date_tk);
CREATE INDEX IDX_FACT_PERF_INSTANCE_START_TIME_TK ON pentaho_operations_mart.FACT_INSTANCE(start_time_tk);
CREATE INDEX IDX_FACT_PERF_INSTANCE_END_DATE_TK ON pentaho_operations_mart.FACT_INSTANCE(end_date_tk);
CREATE INDEX IDX_FACT_PERF_INSTANCE_END_TIME_TK ON pentaho_operations_mart.FACT_INSTANCE(end_time_tk);
CREATE INDEX IDX_FACT_PERF_INSTANCE_SESSION_TK ON pentaho_operations_mart.FACT_INSTANCE(session_tk);
CREATE INDEX IDX_FACT_PERF_INSTANCE_INSTANCE_TK ON pentaho_operations_mart.FACT_INSTANCE(instance_tk);
CREATE INDEX IDX_FACT_PERF_INSTANCE_STATE_TK ON pentaho_operations_mart.FACT_INSTANCE(state_tk);

CREATE TABLE  pentaho_operations_mart.FACT_COMPONENT (
  start_date_tk int NOT NULL,
  start_time_tk int NOT NULL,
  end_date_tk int NOT NULL,
  end_time_tk int NOT NULL,
  session_tk bigint NOT NULL,
  instance_tk bigint NOT NULL,
  state_tk bigint NOT NULL,
  component_tk bigint NOT NULL,
  duration numeric(19,3) NOT NULL
);
CREATE INDEX IDX_FACT_PERF_COMPONENT_START_DATE_TK ON pentaho_operations_mart.FACT_COMPONENT(start_date_tk);
CREATE INDEX IDX_FACT_PERF_COMPONENT_START_TIME_TK ON pentaho_operations_mart.FACT_COMPONENT(start_time_tk);
CREATE INDEX IDX_FACT_PERF_COMPONENT_END_DATE_TK ON pentaho_operations_mart.FACT_COMPONENT(end_date_tk);
CREATE INDEX IDX_FACT_PERF_COMPONENT_END_TIME_TK ON pentaho_operations_mart.FACT_COMPONENT(end_time_tk);
CREATE INDEX IDX_FACT_PERF_COMPONENT_SESSION_TK ON pentaho_operations_mart.FACT_COMPONENT(session_tk);
CREATE INDEX IDX_FACT_PERF_COMPONENT_INSTANCE_TK ON pentaho_operations_mart.FACT_COMPONENT(instance_tk);
CREATE INDEX IDX_FACT_PERF_COMPONENT_COMPONENT_TK ON pentaho_operations_mart.FACT_COMPONENT(component_tk);
CREATE INDEX IDX_FACT_PERF_COMPONENT_STATE_TK ON pentaho_operations_mart.FACT_COMPONENT(state_tk);

CREATE TABLE pentaho_operations_mart.PRO_AUDIT_STAGING (
   job_id varchar(200),
   inst_id varchar(200),
   obj_id varchar(1024),
   obj_type varchar(200),
   actor varchar(200),
   message_type varchar(200),
   message_name varchar(200),
   message_text_value varchar(1024),
   message_num_value numeric(19),
   duration numeric(19, 3),
   audit_time timestamp
);
CREATE INDEX IDX_PRO_AUDIT_STAGING_MESSAGE_TYPE ON pentaho_operations_mart.PRO_AUDIT_STAGING(message_type);

CREATE TABLE pentaho_operations_mart.PRO_AUDIT_TRACKER (
   audit_time timestamp
);
CREATE INDEX IDX_PRO_AUDIT_TRACKER_AUDIT_TIME ON pentaho_operations_mart.PRO_AUDIT_STAGING(audit_time);
INSERT INTO pentaho_operations_mart.PRO_AUDIT_TRACKER values (timestamptz 'epoch');
