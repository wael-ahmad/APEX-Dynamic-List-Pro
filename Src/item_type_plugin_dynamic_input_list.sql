prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- Oracle APEX export file
--
-- You should run this script using a SQL client connected to the database as
-- the owner (parsing schema) of the application or as a database user with the
-- APEX_ADMINISTRATOR_ROLE role.
--
-- This export file has been automatically generated. Modifying this file is not
-- supported by Oracle and can lead to unexpected application and/or instance
-- behavior now or in the future.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_imp.import_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.3'
,p_default_workspace_id=>52684486298427072
,p_default_application_id=>104
,p_default_id_offset=>0
,p_default_owner=>'APEX_24'
);
end;
/
 
prompt APPLICATION 104 - TG_BOT
--
-- Application Export:
--   Application:     104
--   Name:            TG_BOT
--   Date and Time:   21:47 Wednesday May 6, 2026
--   Exported By:     APEX_24
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 732552980942701141
--   Manifest End
--   Version:         24.2.3
--   Instance ID:     697939071843281
--

begin
  -- replace components
  wwv_flow_imp.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/item_type/dynamic_input_list
begin
wwv_flow_imp_shared.create_plugin(
 p_id=>wwv_flow_imp.id(732552980942701141)
,p_plugin_type=>'ITEM TYPE'
,p_name=>'DYNAMIC_INPUT_LIST'
,p_display_name=>'Dynamic List Pro'
,p_supported_component_types=>'APEX_APPLICATION_PAGE_ITEMS'
,p_javascript_file_urls=>wwv_flow_string.join(wwv_flow_t_varchar2(
'#PLUGIN_FILES#sortablejs#MIN#.js',
'#PLUGIN_FILES#pjs#MIN#.js',
''))
,p_css_file_urls=>'#PLUGIN_FILES#pstyle#MIN#.css'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'FUNCTION get_json_from_sql (',
'    p_sql IN CLOB',
') RETURN CLOB IS',
'    l_cursor      INTEGER;',
'    l_col_cnt     INTEGER;',
'    l_desc_tab    DBMS_SQL.DESC_TAB2;',
'',
'    l_id          VARCHAR2(4000);',
'    l_label       VARCHAR2(4000);',
'    l_json        CLOB;',
'    l_rows        NUMBER;',
'',
'    TYPE t_binds IS TABLE OF VARCHAR2(100);',
'    l_binds t_binds := t_binds();',
'',
'    l_pos   PLS_INTEGER := 1;',
'    l_match VARCHAR2(100);',
'',
'    TYPE t_seen IS TABLE OF BOOLEAN INDEX BY VARCHAR2(100);',
'    l_seen t_seen;',
'',
'BEGIN',
'    apex_debug.message(''DTL: get_json_from_sql START'');',
'	',
'    ------------------------------------------------------------------',
'    -- Security Validation',
'    ------------------------------------------------------------------',
'	',
'	IF NOT REGEXP_LIKE(p_sql, ''^\s*SELECT'', ''i'') THEN',
'        raise_application_error(-20001, ''DTL: Only SELECT statements allowed'');',
'    END IF;',
'',
'    IF REGEXP_LIKE(p_sql, ''INSERT|UPDATE|DELETE|DROP|ALTER|;|--|/\*|&'', ''i'') THEN',
'        raise_application_error(-20001, ''DTL: Unsafe SQL detected'');',
'    END IF;',
'	',
'	apex_debug.message(''DTL: SQL = %s'', dbms_lob.substr(p_sql, 1000, 1));',
'',
'    ------------------------------------------------------------------',
'    -- Extract Bind Variables',
'    ------------------------------------------------------------------',
'	',
'	LOOP',
'        l_match := REGEXP_SUBSTR(p_sql, '':[A-Z0-9_]+'', l_pos);',
'',
'        EXIT WHEN l_match IS NULL;',
'',
'        l_match := REPLACE(l_match, '':'');',
'',
'        IF NOT l_seen.EXISTS(l_match) THEN',
'            l_binds.EXTEND;',
'            l_binds(l_binds.COUNT) := l_match;',
'            l_seen(l_match) := TRUE;',
'        END IF;',
'',
'        l_pos := l_pos + 1;',
'    END LOOP;',
'',
'    apex_debug.message(''DTL: Bind count = %s'', l_binds.COUNT);',
'	',
'    ------------------------------------------------------------------',
'    -- Prepare Cursor',
'    ------------------------------------------------------------------',
'    l_cursor := DBMS_SQL.OPEN_CURSOR;',
'',
'    DBMS_SQL.PARSE(l_cursor, p_sql, DBMS_SQL.NATIVE);',
'',
'    ------------------------------------------------------------------',
'    -- Bind Variables from Session State',
'    ------------------------------------------------------------------',
'	',
'	FOR i IN 1 .. l_binds.COUNT LOOP',
'        DECLARE',
'            l_val VARCHAR2(4000);',
'        BEGIN',
'            l_val := apex_util.get_session_state(l_binds(i));',
'',
'            apex_debug.message(''DTL: Bind %s = %s'', l_binds(i), l_val);',
'',
'            IF l_val IS NULL THEN',
'                l_val := '''';',
'            END IF;',
'',
'            DBMS_SQL.BIND_VARIABLE(l_cursor, '':'' || l_binds(i), l_val);',
'        END;',
'    END LOOP;',
'',
'    ------------------------------------------------------------------',
'    -- Define Columns (Expecting 2 columns: ID, LABEL)',
'    ------------------------------------------------------------------',
'	',
'	DBMS_SQL.DESCRIBE_COLUMNS2(l_cursor, l_col_cnt, l_desc_tab);',
'',
'    IF l_col_cnt < 2 THEN',
'        raise_application_error(-20004, ''DTL: SQL must return at least 2 columns'');',
'    END IF;',
'',
'    DBMS_SQL.DEFINE_COLUMN(l_cursor, 1, l_id, 4000);',
'    DBMS_SQL.DEFINE_COLUMN(l_cursor, 2, l_label, 4000);',
'',
'    ------------------------------------------------------------------',
'    -- Execute',
'    ------------------------------------------------------------------',
'    l_rows := DBMS_SQL.EXECUTE(l_cursor);',
'	',
'	apex_debug.message(''DTL: SQL executed'');',
'',
'    ------------------------------------------------------------------',
unistr('    -- \D83D\DCE6 Build JSON'),
'    ------------------------------------------------------------------',
'    apex_json.initialize_clob_output;',
'    apex_json.open_array;',
'',
'    WHILE DBMS_SQL.FETCH_ROWS(l_cursor) > 0 LOOP',
'        DBMS_SQL.COLUMN_VALUE(l_cursor, 1, l_id);',
'        DBMS_SQL.COLUMN_VALUE(l_cursor, 2, l_label);',
'',
'        apex_json.open_object;',
'        apex_json.write(''id'', l_id);',
'        apex_json.write(''label'', l_label);',
'        apex_json.close_object;',
'    END LOOP;',
'',
'    apex_json.close_array;',
'',
'    l_json := apex_json.get_clob_output;',
'    apex_json.free_output;',
'',
'    DBMS_SQL.CLOSE_CURSOR(l_cursor);',
'	',
'	apex_debug.message(''DTL: JSON generated'');',
'    RETURN l_json;',
'',
'EXCEPTION',
'    WHEN OTHERS THEN',
'        apex_debug.error(',
'            p_message => ''DTL ERROR in get_json_from_sql: %s'',',
'            p0        => SQLERRM',
'        );',
'',
'        IF DBMS_SQL.IS_OPEN(l_cursor) THEN',
'            DBMS_SQL.CLOSE_CURSOR(l_cursor);',
'        END IF;',
'',
'        RETURN ''[]'';',
'END;',
'',
'PROCEDURE ajax_get_data (',
'    p_item   IN            apex_plugin.t_item,',
'    p_plugin IN            apex_plugin.t_plugin,',
'    p_param  IN            apex_plugin.t_item_ajax_param,',
'    p_result IN OUT NOCOPY apex_plugin.t_item_ajax_result',
') IS',
'',
'    l_sql    CLOB := p_item.attributes.get_varchar2(''sql_query_source'');',
'    l_json   CLOB;',
'BEGIN',
'	apex_debug.message(''DTL: AJAX START'');',
'',
'    IF l_sql IS NULL THEN',
'        raise_application_error(-20010, ''DTL: SQL Source is NULL'');',
'    END IF;',
'',
'    l_json := get_json_from_sql(l_sql);',
'',
'    apex_debug.message(''DTL: JSON size = %s'', dbms_lob.getlength(l_json));',
'',
'    ------------------------------------------------------------------',
'    -- Response',
'    ------------------------------------------------------------------',
'	apex_json.initialize_clob_output;',
'',
'    htp.p(''{"data":'' || l_json || ''}'');',
'',
'    apex_json.free_output;',
'    apex_debug.message(''DTL: AJAX END'');',
'	',
'	EXCEPTION',
'    WHEN OTHERS THEN',
'        apex_debug.error(',
'            p_message => ''DTL AJAX ERROR: %s'',',
'            p0        => SQLERRM',
'        );',
'',
unistr('        -- \D83D\DD25 Return safe JSON'),
'        htp.p(''{"data":[],"error":"'' || apex_escape.json(SQLERRM) || ''"}'');',
'END;',
'',
'',
'PROCEDURE render (',
'    p_item   IN apex_plugin.t_item, ',
'    p_plugin IN apex_plugin.t_plugin, ',
'    p_param  IN apex_plugin.t_item_render_param, ',
'    p_result IN OUT NOCOPY apex_plugin.t_item_render_result',
') IS ',
'	l_initial_row_count INTEGER := p_item.attributes.get_number(''row_count'');',
'	l_max_row_count 	INTEGER := p_item.attributes.get_number(''max_rows'');',
'    l_label             VARCHAR2(255) := p_item.attributes.get_varchar2(''label'');',
'    l_btns_pos          VARCHAR2(255) := p_item.attributes.get_varchar2(''btns_pos'');',
'    l_btns_style        VARCHAR2(255) := p_item.attributes.get_varchar2(''btns_style'');',
'    l_items_size        VARCHAR2(255) := p_item.attributes.get_varchar2(''items_size'');',
'    l_col_span          VARCHAR2(255) := p_item.attributes.get_varchar2(''col_span'');',
'    l_m_type            VARCHAR2(255) := p_item.attributes.get_varchar2(''m_type'');',
'    l_separator         VARCHAR2(255) := p_item.attributes.get_varchar2(''separator'');',
'    l_validation_type   VARCHAR2(255) := p_item.attributes.get_varchar2(''validation_type'');',
'    l_regex             VARCHAR2(255) := p_item.attributes.get_varchar2(''regex'');',
'    l_allow_dup         VARCHAR2(255) := p_item.attributes.get_varchar2(''allow_duplicates'');',
'    l_mode              VARCHAR2(255) := p_item.attributes.get_varchar2(''mode'');',
'    l_source_type       VARCHAR2(255) := p_item.attributes.get_varchar2(''source_type'');',
'    l_sql_source        CLOB := p_item.attributes.get_varchar2(''sql_query_source'');',
'    l_json              CLOB := p_item.attributes.get_varchar2(''json_array'');',
'    l_page_items        VARCHAR2(255) := p_item.attributes.get_varchar2(''page_items_to_submit'');',
'    l_no_data           VARCHAR2(4000) := p_item.attributes.get_varchar2(''no_data_found'');',
'    l_js_log            VARCHAR2(255) := p_item.attributes.get_varchar2(''js_log'');',
'	l_value      		p_param.value%TYPE := p_param.value;',
'    l_source            CLOB;',
'BEGIN',
'	apex_debug.message(''DTL: Render START - Item: %s'', p_item.name);',
'	',
'    htp.p(''<div class="''||l_col_span||''">'');',
'    htp.p(''     <div class="t-Form-fieldContainer t-Form-fieldContainer--stacked ''||l_items_size||'' apex-item-wrapper apex-item-wrapper--text-field" id="'' || p_item.name || ''_CONTAINER">'');',
'    htp.p(''         <div class="t-Form-labelContainer">'');',
'    htp.p(''             <label for="'' || p_item.name || ''" id="'' || p_item.name || ''_LABEL" class="t-Form-label">''||l_label||''</label> '');    ',
'    htp.p(''         </div>'');',
'    -- Hidden item',
'    htp.p(''         <input type="hidden" id="'' || p_item.name || ''" name="'' || p_item.name || ''" value="'' || apex_escape.html(p_param.value) || ''">'');',
'',
'    -- Container',
'    htp.p(''         <div id="'' || p_item.name || ''_container"></div>'');',
'    htp.p(''     </div>'');',
'    htp.p(''</div>'');',
'',
'    -- JS init',
'    if(l_mode = ''I'') then ',
'        apex_javascript.add_onload_code(',
'            ''apex.dtl_input.init("'' || p_item.name || ''", {'' ||',
'            ''initialCount:'' || nvl(l_initial_row_count, 1) || '','' ||',
'            ''maxItems:'' || nvl(l_max_row_count, 999) || '','' ||',
'            ''btns_pos:"'' || nvl(l_btns_pos, ''E'') || ''",'' ||',
'            ''btns_style:"'' || nvl(l_btns_style, ''D'') || ''",'' || ',
'            ''m_type:"'' || nvl(l_m_type, ''D'') || ''",'' || ',
'            ''separator:"'' || nvl(l_separator, '':'') || ''",'' || ',
'            ''validationType:"'' || nvl(l_validation_type, ''N'') || ''",'' || ',
'            ''regex:"'' || l_regex || ''",'' || ',
'            ''allowDuplicates:"'' || nvl(l_allow_dup, ''N'') || ''",'' || ',
'            ''jsLogEnabled:"'' || nvl(l_js_log, ''N'') || ''"'' || ',
'            ''});''',
'        );',
'    elsif(l_mode = ''R'') then',
'		apex_debug.message(''DTL: Mode = REORDER'');',
'		apex_debug.message(''DTL: Source Type = %s'', l_source_type);',
'		',
'        if(l_source_type = ''S'') then',
'            l_source := get_json_from_sql(l_sql_source);',
'        elsif(l_source_type = ''J'') then ',
'            l_source := l_json;',
'        else',
'            raise_application_error(-20002, ''DTL: Unknown Source Type'');',
'        end if;',
'        apex_javascript.add_onload_code(',
'            ''apex.dtl_reorder.init("'' || p_item.name || ''", {'' ||',
'            ''ajaxIdentifier:"'' || apex_plugin.get_ajax_identifier || ''",'' ||',
'            ''pageItems:"'' || l_page_items || ''",'' ||',
'            ''m_type:"'' || nvl(l_m_type, ''D'') || ''",'' || ',
'            ''separator:"'' || nvl(l_separator, '':'') || ''",'' || ',
'            ''sourceData:'' || apex_escape.js_literal(l_source) || '','' ||',
'            ''noDataFound:"'' || nvl(l_no_data, ''No Data Found'') || ''",'' || ',
'            ''jsLogEnabled:"'' || nvl(l_js_log, ''N'') || ''"'' || ',
'            ''});''',
'        );',
'    else',
'        RETURN;',
'    end if;',
'    ',
'end;',
''))
,p_api_version=>3
,p_render_function=>'render'
,p_ajax_function=>'ajax_get_data'
,p_standard_attributes=>'VISIBLE'
,p_substitute_attributes=>true
,p_version_scn=>1213690169
,p_subscribe_plugin_settings=>true
,p_version_identifier=>'1.0.0'
,p_about_url=>'https://github.com/wael-ahmad/APEX-Dynamic-List-Pro'
,p_files_version=>159
);
wwv_flow_imp_shared.create_plugin_attr_group(
 p_id=>wwv_flow_imp.id(734706246732800587)
,p_plugin_id=>wwv_flow_imp.id(732552980942701141)
,p_title=>'Plugin Mode'
,p_display_sequence=>1
);
wwv_flow_imp_shared.create_plugin_attr_group(
 p_id=>wwv_flow_imp.id(732553255523705745)
,p_plugin_id=>wwv_flow_imp.id(732552980942701141)
,p_title=>'Plugin Settings'
,p_display_sequence=>2
);
wwv_flow_imp_shared.create_plugin_attr_group(
 p_id=>wwv_flow_imp.id(733093462951182494)
,p_plugin_id=>wwv_flow_imp.id(732552980942701141)
,p_title=>'Plugin Multiple Values'
,p_display_sequence=>3
);
wwv_flow_imp_shared.create_plugin_attr_group(
 p_id=>wwv_flow_imp.id(732553570686705745)
,p_plugin_id=>wwv_flow_imp.id(732552980942701141)
,p_title=>'Plugin Layout'
,p_display_sequence=>4
);
wwv_flow_imp_shared.create_plugin_attr_group(
 p_id=>wwv_flow_imp.id(732553952144705746)
,p_plugin_id=>wwv_flow_imp.id(732552980942701141)
,p_title=>'Plugin Style'
,p_display_sequence=>5
);
wwv_flow_imp_shared.create_plugin_attr_group(
 p_id=>wwv_flow_imp.id(733728916181845752)
,p_plugin_id=>wwv_flow_imp.id(732552980942701141)
,p_title=>'Plugin Validations'
,p_display_sequence=>6
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(732554623058713695)
,p_plugin_id=>wwv_flow_imp.id(732552980942701141)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_static_id=>'row_count'
,p_prompt=>'Initial Rows Count'
,p_attribute_type=>'INTEGER'
,p_is_required=>true
,p_default_value=>'1'
,p_unit=>'Row(s)'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(734707212339805734)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'I'
,p_attribute_group_id=>wwv_flow_imp.id(732553255523705745)
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>Number of input rows displayed initially when no value exists.</p>',
'<strong>Used only in Input Mode.</strong>'))
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(732554928283717686)
,p_plugin_id=>wwv_flow_imp.id(732552980942701141)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_static_id=>'max_rows'
,p_prompt=>'Max Rows'
,p_attribute_type=>'INTEGER'
,p_is_required=>true
,p_default_value=>'999'
,p_unit=>'Row(s)'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(734707212339805734)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'I'
,p_attribute_group_id=>wwv_flow_imp.id(732553255523705745)
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>Maximum number of rows allowed.</p>',
'<p>When reached, the add button will be disabled and an event is triggered.</p>'))
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(732555637903725882)
,p_plugin_id=>wwv_flow_imp.id(732552980942701141)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_static_id=>'label'
,p_prompt=>'Label'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_default_value=>'Label'
,p_is_translatable=>true
,p_attribute_group_id=>wwv_flow_imp.id(732553255523705745)
,p_help_text=>'Label displayed above the component.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(732555988527737112)
,p_plugin_id=>wwv_flow_imp.id(732552980942701141)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_static_id=>'items_size'
,p_prompt=>'Items Size'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'t-Form-fieldContainer'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_attribute_group_id=>wwv_flow_imp.id(732553570686705745)
,p_help_text=>'Controls the width and layout style using APEX CSS classes.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(732556230534737907)
,p_plugin_attribute_id=>wwv_flow_imp.id(732555988527737112)
,p_display_sequence=>10
,p_display_value=>'Default'
,p_return_value=>'t-Form-fieldContainer'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(732556672747739134)
,p_plugin_attribute_id=>wwv_flow_imp.id(732555988527737112)
,p_display_sequence=>20
,p_display_value=>'Large'
,p_return_value=>'t-Form-fieldContainer--large'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(732557085983740010)
,p_plugin_attribute_id=>wwv_flow_imp.id(732555988527737112)
,p_display_sequence=>30
,p_display_value=>'XLarge'
,p_return_value=>'t-Form-fieldContainer--xlarge'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(732557587068747062)
,p_plugin_id=>wwv_flow_imp.id(732552980942701141)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>50
,p_static_id=>'btns_pos'
,p_prompt=>'Buttons Position'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'E'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(734707212339805734)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'I'
,p_lov_type=>'STATIC'
,p_attribute_group_id=>wwv_flow_imp.id(732553570686705745)
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<strong>Defines position of add/remove buttons:</strong>',
'<ul>',
'    <li>Start: Before input field</li>',
'    <li>End: After input field</li>',
'</ul>'))
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(732557808671747915)
,p_plugin_attribute_id=>wwv_flow_imp.id(732557587068747062)
,p_display_sequence=>10
,p_display_value=>'End'
,p_return_value=>'E'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(732559101910749310)
,p_plugin_attribute_id=>wwv_flow_imp.id(732557587068747062)
,p_display_sequence=>20
,p_display_value=>'Start'
,p_return_value=>'S'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(732561489814822634)
,p_plugin_id=>wwv_flow_imp.id(732552980942701141)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>60
,p_static_id=>'col_span'
,p_prompt=>'Column Span'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'col col-12 apex-col-auto col-start col-end'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_attribute_group_id=>wwv_flow_imp.id(732553570686705745)
,p_help_text=>'Defines column width within APEX grid system.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(732561994948824674)
,p_plugin_attribute_id=>wwv_flow_imp.id(732561489814822634)
,p_display_sequence=>10
,p_display_value=>'Automatic'
,p_return_value=>'col col-12 apex-col-auto col-start col-end'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(732562342558826207)
,p_plugin_attribute_id=>wwv_flow_imp.id(732561489814822634)
,p_display_sequence=>20
,p_display_value=>'1'
,p_return_value=>'col col-1  col-start'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(732562726752827417)
,p_plugin_attribute_id=>wwv_flow_imp.id(732561489814822634)
,p_display_sequence=>30
,p_display_value=>'2'
,p_return_value=>'col col-2  col-start'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(732563148362828258)
,p_plugin_attribute_id=>wwv_flow_imp.id(732561489814822634)
,p_display_sequence=>40
,p_display_value=>'3'
,p_return_value=>'col col-3  col-start'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(732563556466829089)
,p_plugin_attribute_id=>wwv_flow_imp.id(732561489814822634)
,p_display_sequence=>50
,p_display_value=>'4'
,p_return_value=>'col col-4  col-start'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(732563963574830031)
,p_plugin_attribute_id=>wwv_flow_imp.id(732561489814822634)
,p_display_sequence=>60
,p_display_value=>'5'
,p_return_value=>'col col-5  col-start'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(732564348426830873)
,p_plugin_attribute_id=>wwv_flow_imp.id(732561489814822634)
,p_display_sequence=>70
,p_display_value=>'6'
,p_return_value=>'col col-6  col-start'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(732564758438831571)
,p_plugin_attribute_id=>wwv_flow_imp.id(732561489814822634)
,p_display_sequence=>80
,p_display_value=>'7'
,p_return_value=>'col col-7  col-start'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(732565151421832298)
,p_plugin_attribute_id=>wwv_flow_imp.id(732561489814822634)
,p_display_sequence=>90
,p_display_value=>'8'
,p_return_value=>'col col-8  col-start'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(732565578552833385)
,p_plugin_attribute_id=>wwv_flow_imp.id(732561489814822634)
,p_display_sequence=>100
,p_display_value=>'9'
,p_return_value=>'col col-9  col-start'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(732565957444834249)
,p_plugin_attribute_id=>wwv_flow_imp.id(732561489814822634)
,p_display_sequence=>110
,p_display_value=>'10'
,p_return_value=>'col col-10  col-start'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(732566393193834978)
,p_plugin_attribute_id=>wwv_flow_imp.id(732561489814822634)
,p_display_sequence=>120
,p_display_value=>'11'
,p_return_value=>'col col-11  col-start'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(732566778514835744)
,p_plugin_attribute_id=>wwv_flow_imp.id(732561489814822634)
,p_display_sequence=>130
,p_display_value=>'12'
,p_return_value=>'col col-12  col-start'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(732567251187842010)
,p_plugin_id=>wwv_flow_imp.id(732552980942701141)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>7
,p_display_sequence=>70
,p_static_id=>'btns_style'
,p_prompt=>'Buttons Style'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'D'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(734707212339805734)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'I'
,p_lov_type=>'STATIC'
,p_attribute_group_id=>wwv_flow_imp.id(732553952144705746)
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<strong>Controls button appearance:</strong>',
'<ul>',
'    <li>Default (minimal)</li>',
'    <li>Danger for Remove / Primary for Add (colored buttons)</li>',
'</ul>'))
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(732567544216842653)
,p_plugin_attribute_id=>wwv_flow_imp.id(732567251187842010)
,p_display_sequence=>10
,p_display_value=>'Default'
,p_return_value=>'D'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(732567938602846574)
,p_plugin_attribute_id=>wwv_flow_imp.id(732567251187842010)
,p_display_sequence=>20
,p_display_value=>'Danger for Remove / Primary for Add'
,p_return_value=>'T'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(733094151460186620)
,p_plugin_id=>wwv_flow_imp.id(732552980942701141)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>8
,p_display_sequence=>80
,p_static_id=>'m_type'
,p_prompt=>'Type'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'D'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_attribute_group_id=>wwv_flow_imp.id(733093462951182494)
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<strong>Defines how values are stored:</strong>',
'<ul>',
'    <li>Delimited: Values joined using separator.</li>',
'    <li>JSON: Stored as JSON array.</li>',
'</ul>'))
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(733095047838188402)
,p_plugin_attribute_id=>wwv_flow_imp.id(733094151460186620)
,p_display_sequence=>10
,p_display_value=>'Delimited List'
,p_return_value=>'D'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(733095425349189380)
,p_plugin_attribute_id=>wwv_flow_imp.id(733094151460186620)
,p_display_sequence=>20
,p_display_value=>'JSON Array'
,p_return_value=>'J'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(733097799610209959)
,p_plugin_id=>wwv_flow_imp.id(732552980942701141)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>9
,p_display_sequence=>90
,p_static_id=>'separator'
,p_prompt=>'Separator'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_default_value=>':'
,p_display_length=>1
,p_max_length=>1
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(733094151460186620)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'D'
,p_attribute_group_id=>wwv_flow_imp.id(733093462951182494)
,p_examples=>': OR ,'
,p_help_text=>'Character used to separate values when Type = Delimited.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(733717816738779549)
,p_plugin_id=>wwv_flow_imp.id(732552980942701141)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>10
,p_display_sequence=>100
,p_static_id=>'validation_type'
,p_prompt=>'Validation Type'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'N'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(734707212339805734)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'I'
,p_lov_type=>'STATIC'
,p_attribute_group_id=>wwv_flow_imp.id(733728916181845752)
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<strong>Defines validation applied to each value:</strong>',
'<ul>',
'    <li>None</li>',
'    <li>Email</li>',
'    <li>Phone</li>',
'    <li>Regex</li>',
'</ul>'))
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(733719538022781106)
,p_plugin_attribute_id=>wwv_flow_imp.id(733717816738779549)
,p_display_sequence=>10
,p_display_value=>'None'
,p_return_value=>'N'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(733719908647782520)
,p_plugin_attribute_id=>wwv_flow_imp.id(733717816738779549)
,p_display_sequence=>20
,p_display_value=>'Email'
,p_return_value=>'E'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(733720339898783903)
,p_plugin_attribute_id=>wwv_flow_imp.id(733717816738779549)
,p_display_sequence=>30
,p_display_value=>'Phone'
,p_return_value=>'P'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(733720750301785290)
,p_plugin_attribute_id=>wwv_flow_imp.id(733717816738779549)
,p_display_sequence=>40
,p_display_value=>'Regex'
,p_return_value=>'R'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(733730152970856061)
,p_plugin_id=>wwv_flow_imp.id(732552980942701141)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>11
,p_display_sequence=>110
,p_static_id=>'regex'
,p_prompt=>'Regex'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_display_length=>100
,p_max_length=>100
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(733717816738779549)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'R'
,p_attribute_group_id=>wwv_flow_imp.id(733728916181845752)
,p_help_text=>'Custom regular expression used when Validation Type = Regex.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(733732141074874285)
,p_plugin_id=>wwv_flow_imp.id(732552980942701141)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>12
,p_display_sequence=>120
,p_static_id=>'allow_duplicates'
,p_prompt=>'Allow Duplicates'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(734707212339805734)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'I'
,p_attribute_group_id=>wwv_flow_imp.id(733728916181845752)
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<strong>Allows or prevents duplicate values:</strong>',
'<ul>',
'    <li>Yes: duplicates allowed</li>',
'    <li>No: duplicates highlighted as invalid</li>',
'</ul>'))
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(734707212339805734)
,p_plugin_id=>wwv_flow_imp.id(732552980942701141)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>13
,p_display_sequence=>130
,p_static_id=>'mode'
,p_prompt=>'Mode'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'I'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_attribute_group_id=>wwv_flow_imp.id(734706246732800587)
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<strong>Defines how the plugin behaves:</strong>',
'<ul>',
'    <li>Input: Allows users to enter multiple values dynamically.</li>',
'    <li>Reorder: Displays a list (from JSON or SQL) and allows drag & drop reordering.</li>',
'</ul>'))
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(734707880940806545)
,p_plugin_attribute_id=>wwv_flow_imp.id(734707212339805734)
,p_display_sequence=>10
,p_display_value=>'Input'
,p_return_value=>'I'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(734708253208807897)
,p_plugin_attribute_id=>wwv_flow_imp.id(734707212339805734)
,p_display_sequence=>20
,p_display_value=>'Reorder'
,p_return_value=>'R'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(734710421793822106)
,p_plugin_id=>wwv_flow_imp.id(732552980942701141)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>14
,p_display_sequence=>140
,p_static_id=>'source_type'
,p_prompt=>'Source Type'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'J'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(734707212339805734)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'R'
,p_lov_type=>'STATIC'
,p_attribute_group_id=>wwv_flow_imp.id(732553255523705745)
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<strong>Defines the data source in Reorder Mode:</strong>',
'<ul>',
'    <li>JSON: Static JSON array.</li>',
'    <li>SQL Query: Dynamic data from database.</li>',
'</ul>'))
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(734711488482826219)
,p_plugin_attribute_id=>wwv_flow_imp.id(734710421793822106)
,p_display_sequence=>10
,p_display_value=>'JSON Array'
,p_return_value=>'J'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(734712463129828717)
,p_plugin_attribute_id=>wwv_flow_imp.id(734710421793822106)
,p_display_sequence=>20
,p_display_value=>'SQL Query Returning one Column'
,p_return_value=>'S'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(734714171512838217)
,p_plugin_id=>wwv_flow_imp.id(732552980942701141)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>15
,p_display_sequence=>150
,p_static_id=>'sql_query_source'
,p_prompt=>'SQL Query'
,p_attribute_type=>'SQL'
,p_is_required=>true
,p_sql_min_column_count=>2
,p_sql_max_column_count=>2
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(734710421793822106)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'S'
,p_attribute_group_id=>wwv_flow_imp.id(732553255523705745)
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>SELECT id, name FROM users ORDER BY name</p>',
'<strong>You can use bind variables (e.g. :P1_ITEM) with Page Items to Submit.</strong>'))
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<strong>SQL query returning exactly two columns:</strong>',
'<ul>',
'    <li>First column: ID</li>',
'    <li>Second column: Label</li>',
'</ul>'))
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(734717830220850679)
,p_plugin_id=>wwv_flow_imp.id(732552980942701141)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>16
,p_display_sequence=>160
,p_static_id=>'json_array'
,p_prompt=>'JSON Array'
,p_attribute_type=>'TEXTAREA'
,p_is_required=>true
,p_max_length=>4000
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(734710421793822106)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'J'
,p_attribute_group_id=>wwv_flow_imp.id(732553255523705745)
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'[',
'  {"id":1,"label":"James"},',
'  {"id":2,"label":"John"}',
']'))
,p_help_text=>'<strong>JSON array used as data source.</strong>'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(735491316454562417)
,p_plugin_id=>wwv_flow_imp.id(732552980942701141)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>17
,p_display_sequence=>170
,p_static_id=>'page_items_to_submit'
,p_prompt=>'Page Items To Submit'
,p_attribute_type=>'PAGE ITEMS'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(734710421793822106)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'S'
,p_attribute_group_id=>wwv_flow_imp.id(732553255523705745)
,p_examples=>'P1_ITEM_1,P1_ITEM_2'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>Comma-separated list of page items sent during AJAX calls.</p>',
'<p>Required when using bind variables in SQL query.</p>'))
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(736444730180248243)
,p_plugin_id=>wwv_flow_imp.id(732552980942701141)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>18
,p_display_sequence=>180
,p_static_id=>'no_data_found'
,p_prompt=>'No Data Found Message'
,p_attribute_type=>'TEXTAREA'
,p_is_required=>false
,p_max_length=>4000
,p_is_translatable=>true
,p_depending_on_attribute_id=>wwv_flow_imp.id(734707212339805734)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'R'
,p_attribute_group_id=>wwv_flow_imp.id(732553255523705745)
,p_help_text=>'Message displayed when no data is returned from the source.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(737062070985905013)
,p_plugin_id=>wwv_flow_imp.id(732552980942701141)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>19
,p_display_sequence=>190
,p_static_id=>'js_log'
,p_prompt=>'JS Log Enabled'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_attribute_group_id=>wwv_flow_imp.id(733728916181845752)
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Enables browser console logging for debugging purposes.',
'<strong>Should be disabled in production.</strong>'))
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(737080326318102023)
,p_plugin_id=>wwv_flow_imp.id(732552980942701141)
,p_name=>'data_refreshed'
,p_display_name=>'Data Refreshed'
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(737079553681102022)
,p_plugin_id=>wwv_flow_imp.id(732552980942701141)
,p_name=>'duplicates_found'
,p_display_name=>'Duplicates Found'
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(733116150471429573)
,p_plugin_id=>wwv_flow_imp.id(732552980942701141)
,p_name=>'max_rows_reached'
,p_display_name=>'Max Rows Reached'
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(733115398613429572)
,p_plugin_id=>wwv_flow_imp.id(732552980942701141)
,p_name=>'row_added'
,p_display_name=>'Row Added'
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(733115738847429573)
,p_plugin_id=>wwv_flow_imp.id(732552980942701141)
,p_name=>'row_deleted'
,p_display_name=>'Row Deleted'
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(737079966052102022)
,p_plugin_id=>wwv_flow_imp.id(732552980942701141)
,p_name=>'row_reordered'
,p_display_name=>'Rows Reordered'
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(737078774170102020)
,p_plugin_id=>wwv_flow_imp.id(732552980942701141)
,p_name=>'validation_failed'
,p_display_name=>'Validation Failed'
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(737079132890102022)
,p_plugin_id=>wwv_flow_imp.id(732552980942701141)
,p_name=>'value_changed'
,p_display_name=>'Value Changed'
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '2E64746C2D726F77207B0D0A20202020646973706C61793A20666C65783B0D0A202020206761703A203670783B0D0A202020206D617267696E2D626F74746F6D3A203670783B0D0A20202020616C69676E2D6974656D733A2063656E7465723B0D0A7D0D';
wwv_flow_imp.g_varchar2_table(2) := '0A0D0A2E64746C2D6572726F727B0D0A20202020626F726465722D636F6C6F723A207265642021696D706F7274616E743B0D0A7D0D0A0D0A2E64746C2D6475706C696361746520696E7075747B0D0A202020206261636B67726F756E643A20626C75653B';
wwv_flow_imp.g_varchar2_table(3) := '0D0A20202020636F6C6F723A2077686974653B0D0A7D0D0A0D0A0D0A2E64746C2D68616E646C65207B0D0A20202020637572736F723A20677261623B0D0A20202020636F6C6F723A20233838383B0D0A7D0D0A0D0A2E64746C2D726F773A616374697665';
wwv_flow_imp.g_varchar2_table(4) := '202E64746C2D68616E646C65207B0D0A20202020637572736F723A206772616262696E673B0D0A7D0D0A0D0A2E64746C2D647261672D67686F7374207B0D0A202020206F7061636974793A20302E353B0D0A7D';
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(732966401568879832)
,p_plugin_id=>wwv_flow_imp.id(732552980942701141)
,p_file_name=>'pstyle.css'
,p_mime_type=>'text/css'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '617065782E64746C5F696E707574203D202866756E6374696F6E202829207B0D0A0D0A2020202066756E6374696F6E20696E697428704974656D49642C206F7074696F6E7329207B0D0A202020202020202076617220636F7265203D20617065782E6479';
wwv_flow_imp.g_varchar2_table(2) := '6E616D6963436F72653B0D0A2020202020202020636F72652E6465627567203D20286F7074696F6E732E6A734C6F67456E61626C6564203D3D3D20225922293B0D0A2020202020202020636F72652E6C6F672822494E4954222C20704974656D49642C20';
wwv_flow_imp.g_varchar2_table(3) := '6F7074696F6E73293B0D0A0D0A202020202020202076617220636F6E7461696E6572203D20646F63756D656E742E676574456C656D656E744279496428704974656D4964202B20225F636F6E7461696E657222293B0D0A20202020202020207661722068';
wwv_flow_imp.g_varchar2_table(4) := '696464656E203D20646F63756D656E742E676574456C656D656E744279496428704974656D4964293B0D0A0D0A20202020202020206966202821636F6E7461696E6572207C7C202168696464656E29207B0D0A202020202020202020202020636F72652E';
wwv_flow_imp.g_varchar2_table(5) := '6572726F722822436F6E7461696E65722F48696464656E206E6F7420666F756E64222C20704974656D4964293B0D0A20202020202020202020202072657475726E3B0D0A20202020202020207D0D0A0D0A20202020202020202F2A203D3D3D3D3D3D3D3D';
wwv_flow_imp.g_varchar2_table(6) := '3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D0D0A2020202020202020202020436F6E6669670D0A20202020202020203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D202A2F0D0A2020202020202020766172206D61784974656D73203D206F';
wwv_flow_imp.g_varchar2_table(7) := '7074696F6E732E6D61784974656D73207C7C203939393B0D0A202020202020202076617220696E697469616C436F756E74203D206F7074696F6E732E696E697469616C436F756E74207C7C20313B0D0A20202020202020207661722062746E73506F7320';
wwv_flow_imp.g_varchar2_table(8) := '3D206F7074696F6E732E62746E735F706F73207C7C202245223B0D0A20202020202020207661722062746E735374796C65203D206F7074696F6E732E62746E735F7374796C65207C7C202244223B0D0A2020202020202020766172206D5479706520203D';
wwv_flow_imp.g_varchar2_table(9) := '206F7074696F6E732E6D5F74797065207C7C202244223B0D0A202020202020202076617220736570617261746F72203D206F7074696F6E732E736570617261746F72207C7C20223A223B0D0A20202020202020207661722076616C69646174696F6E5479';
wwv_flow_imp.g_varchar2_table(10) := '7065203D206F7074696F6E732E76616C69646174696F6E54797065207C7C20224E223B0D0A2020202020202020766172207265676578203D206F7074696F6E732E72656765783B0D0A202020202020202076617220616C6C6F774475706C696361746573';
wwv_flow_imp.g_varchar2_table(11) := '203D20286F7074696F6E732E616C6C6F774475706C696361746573203D3D3D20225922293B0D0A0D0A20202020202020202F2A203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D0D0A202020202020202020202048656C706572730D0A20';
wwv_flow_imp.g_varchar2_table(12) := '202020202020203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D202A2F0D0A202020202020202066756E6374696F6E2076616C69646174652876616C29207B0D0A20202020202020202020202072657475726E20636F72652E76616C6964';
wwv_flow_imp.g_varchar2_table(13) := '61746556616C75652876616C2C2076616C69646174696F6E547970652C207265676578293B0D0A20202020202020207D0D0A0D0A20202020202020202F2A203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D0D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(14) := '20526F77204372656174696F6E0D0A20202020202020203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D202A2F0D0A0D0A202020202020202066756E6374696F6E20637265617465526F772876616C756529207B0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(15) := '202020200D0A20202020202020202020202076617220726F77203D20646F63756D656E742E637265617465456C656D656E74282264697622293B0D0A202020202020202020202020726F772E636C6173734E616D65203D202264746C2D726F7720742D46';
wwv_flow_imp.g_varchar2_table(16) := '6F726D2D696E707574436F6E7461696E6572223B0D0A0D0A20202020202020202020202076617220696E707574203D20646F63756D656E742E637265617465456C656D656E742822696E70757422293B0D0A202020202020202020202020696E7075742E';
wwv_flow_imp.g_varchar2_table(17) := '74797065203D202274657874223B0D0A202020202020202020202020696E7075742E636C6173734E616D65203D2022746578745F6669656C6420617065782D6974656D2D74657874223B0D0A202020202020202020202020696E7075742E76616C756520';
wwv_flow_imp.g_varchar2_table(18) := '3D2076616C7565207C7C2022223B0D0A202020202020202020202020696E7075742E73697A65203D20223330223B0D0A0D0A2020202020202020202020207661722072656D6F766542746E203D20646F63756D656E742E637265617465456C656D656E74';
wwv_flow_imp.g_varchar2_table(19) := '2822627574746F6E22293B0D0A20202020202020202020202072656D6F766542746E2E74797065203D2022627574746F6E223B0D0A20202020202020202020202072656D6F766542746E2E636C6173734E616D65203D202862746E735374796C65203D3D';
wwv_flow_imp.g_varchar2_table(20) := '3D20224422290D0A202020202020202020202020202020203F2022742D427574746F6E20742D427574746F6E2D2D6E6F554920742D427574746F6E2D2D69636F6E2064746C2D72656D6F7665220D0A202020202020202020202020202020203A2022742D';
wwv_flow_imp.g_varchar2_table(21) := '427574746F6E20742D427574746F6E2D2D69636F6E2064746C2D72656D6F766520742D427574746F6E2D2D64616E676572223B0D0A0D0A20202020202020202020202072656D6F766542746E2E696E6E657248544D4C203D20273C7370616E20636C6173';
wwv_flow_imp.g_varchar2_table(22) := '733D2266612066612D74696D6573223E3C2F7370616E3E273B0D0A0D0A20202020202020202020202072656D6F766542746E2E6F6E636C69636B203D2066756E6374696F6E202829207B0D0A20202020202020202020202020202020747279207B0D0A20';
wwv_flow_imp.g_varchar2_table(23) := '20202020202020202020202020202020202020726F772E72656D6F766528293B0D0A20202020202020202020202020202020202020207265667265736828293B0D0A0D0A2020202020202020202020202020202020202020636F72652E74726967676572';
wwv_flow_imp.g_varchar2_table(24) := '4576656E742868696464656E2C2022726F775F64656C65746564222C207B0D0A202020202020202020202020202020202020202020202020636F756E743A20636F6E7461696E65722E6368696C6472656E2E6C656E6774682C0D0A202020202020202020';
wwv_flow_imp.g_varchar2_table(25) := '2020202020202020202020202020206974656D3A20704974656D49640D0A20202020202020202020202020202020202020207D293B0D0A0D0A2020202020202020202020202020202020202020636F72652E6C6F672822526F772064656C657465642229';
wwv_flow_imp.g_varchar2_table(26) := '3B0D0A0D0A202020202020202020202020202020207D20636174636820286529207B0D0A2020202020202020202020202020202020202020636F72652E6572726F72282252656D6F7665206572726F72222C2065293B0D0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(27) := '202020207D0D0A2020202020202020202020207D3B0D0A0D0A2020202020202020202020207661722061646442746E203D20646F63756D656E742E637265617465456C656D656E742822627574746F6E22293B0D0A202020202020202020202020616464';
wwv_flow_imp.g_varchar2_table(28) := '42746E2E74797065203D2022627574746F6E223B0D0A20202020202020202020202061646442746E2E636C6173734E616D65203D202862746E735374796C65203D3D3D20224422290D0A202020202020202020202020202020203F2022742D427574746F';
wwv_flow_imp.g_varchar2_table(29) := '6E20742D427574746F6E2D2D6E6F554920742D427574746F6E2D2D69636F6E2064746C2D616464220D0A202020202020202020202020202020203A2022742D427574746F6E20742D427574746F6E2D2D69636F6E2064746C2D61646420742D427574746F';
wwv_flow_imp.g_varchar2_table(30) := '6E2D2D7072696D617279223B0D0A0D0A20202020202020202020202061646442746E2E696E6E657248544D4C203D20273C7370616E20636C6173733D2266612066612D706C7573223E3C2F7370616E3E273B0D0A0D0A2020202020202020202020206164';
wwv_flow_imp.g_varchar2_table(31) := '6442746E2E6F6E636C69636B203D2066756E6374696F6E202829207B0D0A20202020202020202020202020202020747279207B0D0A0D0A202020202020202020202020202020202020202069662028636F6E7461696E65722E6368696C6472656E2E6C65';
wwv_flow_imp.g_varchar2_table(32) := '6E677468203E3D206D61784974656D7329207B0D0A202020202020202020202020202020202020202020202020636F72652E747269676765724576656E742868696464656E2C20226D61785F726F77735F72656163686564222C207B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(33) := '202020202020202020202020202020202020202020206D61783A206D61784974656D730D0A2020202020202020202020202020202020202020202020207D293B0D0A0D0A202020202020202020202020202020202020202020202020636F72652E6C6F67';
wwv_flow_imp.g_varchar2_table(34) := '28224D617820726F7773207265616368656422293B0D0A20202020202020202020202020202020202020202020202072657475726E3B0D0A20202020202020202020202020202020202020207D0D0A0D0A20202020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(35) := '20696620282176616C696461746528696E7075742E76616C75652929207B0D0A202020202020202020202020202020202020202020202020696E7075742E636C6173734C6973742E616464282264746C2D6572726F7222293B0D0A0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(36) := '2020202020202020202020202020202020636F72652E747269676765724576656E742868696464656E2C202276616C69646174696F6E5F6661696C6564222C207B0D0A2020202020202020202020202020202020202020202020202020202076616C7565';
wwv_flow_imp.g_varchar2_table(37) := '3A20696E7075742E76616C75652C0D0A202020202020202020202020202020202020202020202020202020206974656D3A20704974656D49640D0A2020202020202020202020202020202020202020202020207D293B0D0A0D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(38) := '202020202020202020202020202072657475726E3B0D0A20202020202020202020202020202020202020207D20656C7365207B0D0A202020202020202020202020202020202020202020202020696E7075742E636C6173734C6973742E72656D6F766528';
wwv_flow_imp.g_varchar2_table(39) := '2264746C2D6572726F7222293B0D0A20202020202020202020202020202020202020207D0D0A0D0A2020202020202020202020202020202020202020766172206E6577526F77203D20637265617465526F77282222293B0D0A2020202020202020202020';
wwv_flow_imp.g_varchar2_table(40) := '202020202020202020636F6E7461696E65722E617070656E644368696C64286E6577526F77293B0D0A0D0A20202020202020202020202020202020202020207265667265736828293B0D0A0D0A2020202020202020202020202020202020202020636F72';
wwv_flow_imp.g_varchar2_table(41) := '652E747269676765724576656E742868696464656E2C2022726F775F6164646564222C207B0D0A202020202020202020202020202020202020202020202020636F756E743A20636F6E7461696E65722E6368696C6472656E2E6C656E6774682C0D0A2020';
wwv_flow_imp.g_varchar2_table(42) := '202020202020202020202020202020202020202020206974656D3A20704974656D49640D0A20202020202020202020202020202020202020207D293B0D0A0D0A20202020202020202020202020202020202020206E6577526F772E717565727953656C65';
wwv_flow_imp.g_varchar2_table(43) := '63746F722822696E70757422292E666F63757328293B0D0A0D0A202020202020202020202020202020207D20636174636820286529207B0D0A2020202020202020202020202020202020202020636F72652E6572726F722822416464206572726F72222C';
wwv_flow_imp.g_varchar2_table(44) := '2065293B0D0A202020202020202020202020202020207D0D0A2020202020202020202020207D3B0D0A0D0A2020202020202020202020206966202862746E73506F73203D3D3D2022532229207B0D0A20202020202020202020202020202020726F772E61';
wwv_flow_imp.g_varchar2_table(45) := '7070656E644368696C642872656D6F766542746E293B0D0A20202020202020202020202020202020726F772E617070656E644368696C642861646442746E293B0D0A20202020202020202020202020202020726F772E617070656E644368696C6428696E';
wwv_flow_imp.g_varchar2_table(46) := '707574293B0D0A2020202020202020202020207D20656C7365207B0D0A20202020202020202020202020202020726F772E617070656E644368696C6428696E707574293B0D0A20202020202020202020202020202020726F772E617070656E644368696C';
wwv_flow_imp.g_varchar2_table(47) := '642872656D6F766542746E293B0D0A20202020202020202020202020202020726F772E617070656E644368696C642861646442746E293B0D0A2020202020202020202020207D0D0A0D0A2020202020202020202020202F2A204576656E7473202A2F0D0A';
wwv_flow_imp.g_varchar2_table(48) := '202020202020202020202020696E7075742E6164644576656E744C697374656E65722822696E707574222C0D0A20202020202020202020202020202020636F72652E6465626F756E636528726566726573682C20333030290D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(49) := '2020293B0D0A0D0A202020202020202020202020696E7075742E6164644576656E744C697374656E657228226B6579646F776E222C2066756E6374696F6E20286529207B0D0A2020202020202020202020202020202069662028652E6B6579203D3D3D20';
wwv_flow_imp.g_varchar2_table(50) := '22456E7465722229207B0D0A2020202020202020202020202020202020202020652E70726576656E7444656661756C7428293B0D0A202020202020202020202020202020202020202061646442746E2E636C69636B28293B0D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(51) := '2020202020207D0D0A2020202020202020202020207D293B0D0A0D0A20202020202020202020202072657475726E20726F773B0D0A20202020202020207D0D0A0D0A20202020202020202F2A203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D';
wwv_flow_imp.g_varchar2_table(52) := '3D3D0D0A2020202020202020202020526566726573680D0A20202020202020203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D202A2F0D0A0D0A202020202020202066756E6374696F6E20726566726573682829207B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(53) := '202020202020747279207B0D0A2020202020202020202020202020202076617220726F7773203D20636F6E7461696E65722E717565727953656C6563746F72416C6C28222E64746C2D726F7722293B0D0A0D0A2020202020202020202020202020202076';
wwv_flow_imp.g_varchar2_table(54) := '61722076616C756573203D205B5D3B0D0A20202020202020202020202020202020766172207365656E203D206E65772053657428293B0D0A20202020202020202020202020202020766172206861734475706C696361746573203D2066616C73653B0D0A';
wwv_flow_imp.g_varchar2_table(55) := '0D0A20202020202020202020202020202020726F77732E666F72456163682866756E6374696F6E2028726F7729207B0D0A0D0A202020202020202020202020202020202020202076617220696E707574203D20726F772E717565727953656C6563746F72';
wwv_flow_imp.g_varchar2_table(56) := '2822696E70757422293B0D0A20202020202020202020202020202020202020207661722076616C203D20696E7075742E76616C75652E7472696D28293B0D0A0D0A20202020202020202020202020202020202020202F2F2056616C69646174696F6E2055';
wwv_flow_imp.g_varchar2_table(57) := '490D0A2020202020202020202020202020202020202020696620282176616C69646174652876616C2929207B0D0A202020202020202020202020202020202020202020202020696E7075742E636C6173734C6973742E616464282264746C2D6572726F72';
wwv_flow_imp.g_varchar2_table(58) := '22293B0D0A20202020202020202020202020202020202020207D20656C7365207B0D0A202020202020202020202020202020202020202020202020696E7075742E636C6173734C6973742E72656D6F7665282264746C2D6572726F7222293B0D0A202020';
wwv_flow_imp.g_varchar2_table(59) := '20202020202020202020202020202020207D0D0A0D0A20202020202020202020202020202020202020202F2F204475706C696361746520646574656374696F6E0D0A20202020202020202020202020202020202020206966202821616C6C6F774475706C';
wwv_flow_imp.g_varchar2_table(60) := '6963617465732026262076616C20213D3D202222202626207365656E2E6861732876616C2929207B0D0A202020202020202020202020202020202020202020202020726F772E636C6173734C6973742E616464282264746C2D6475706C69636174652229';
wwv_flow_imp.g_varchar2_table(61) := '3B0D0A2020202020202020202020202020202020202020202020206861734475706C696361746573203D20747275653B0D0A20202020202020202020202020202020202020207D20656C7365207B0D0A2020202020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(62) := '20202020726F772E636C6173734C6973742E72656D6F7665282264746C2D6475706C696361746522293B0D0A20202020202020202020202020202020202020207D0D0A0D0A20202020202020202020202020202020202020206966202876616C20213D3D';
wwv_flow_imp.g_varchar2_table(63) := '20222229207B0D0A20202020202020202020202020202020202020202020202076616C7565732E707573682876616C293B0D0A20202020202020202020202020202020202020207D0D0A0D0A20202020202020202020202020202020202020207365656E';
wwv_flow_imp.g_varchar2_table(64) := '2E6164642876616C293B0D0A202020202020202020202020202020207D293B0D0A0D0A202020202020202020202020202020207661722066696E616C56616C7565203D20286D54797065203D3D3D20224A22290D0A202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(65) := '20202020203F204A534F4E2E737472696E676966792876616C756573290D0A20202020202020202020202020202020202020203A2076616C7565732E6A6F696E28736570617261746F72293B0D0A0D0A2020202020202020202020202020202061706578';
wwv_flow_imp.g_varchar2_table(66) := '2E6974656D28704974656D4964292E73657456616C75652866696E616C56616C7565293B0D0A0D0A202020202020202020202020202020202F2F20427574746F6E7320636F6E74726F6C0D0A20202020202020202020202020202020726F77732E666F72';
wwv_flow_imp.g_varchar2_table(67) := '456163682866756E6374696F6E2028726F772C20696E64657829207B0D0A20202020202020202020202020202020202020207661722072656D6F766542746E203D20726F772E717565727953656C6563746F7228222E64746C2D72656D6F766522293B0D';
wwv_flow_imp.g_varchar2_table(68) := '0A20202020202020202020202020202020202020207661722061646442746E203D20726F772E717565727953656C6563746F7228222E64746C2D61646422293B0D0A0D0A202020202020202020202020202020202020202072656D6F766542746E2E7374';
wwv_flow_imp.g_varchar2_table(69) := '796C652E646973706C6179203D0D0A20202020202020202020202020202020202020202020202028726F77732E6C656E677468203D3D3D203129203F20226E6F6E6522203A2022696E6C696E652D626C6F636B223B0D0A0D0A2020202020202020202020';
wwv_flow_imp.g_varchar2_table(70) := '20202020202020202061646442746E2E7374796C652E646973706C6179203D0D0A20202020202020202020202020202020202020202020202028696E646578203D3D3D20726F77732E6C656E677468202D203120262620726F77732E6C656E677468203C';
wwv_flow_imp.g_varchar2_table(71) := '206D61784974656D73290D0A202020202020202020202020202020202020202020202020202020203F2022696E6C696E652D626C6F636B220D0A202020202020202020202020202020202020202020202020202020203A20226E6F6E65223B0D0A202020';
wwv_flow_imp.g_varchar2_table(72) := '202020202020202020202020207D293B0D0A0D0A20202020202020202020202020202020636F72652E747269676765724576656E742868696464656E2C202276616C75655F6368616E676564222C207B0D0A202020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(73) := '202076616C7565733A2076616C7565732C0D0A20202020202020202020202020202020202020206974656D3A20704974656D49640D0A202020202020202020202020202020207D293B0D0A0D0A2020202020202020202020202020202069662028686173';
wwv_flow_imp.g_varchar2_table(74) := '4475706C69636174657329207B0D0A2020202020202020202020202020202020202020636F72652E747269676765724576656E742868696464656E2C20226475706C6963617465735F666F756E64222C207B0D0A20202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(75) := '20202020202020206974656D3A20704974656D49640D0A20202020202020202020202020202020202020207D293B0D0A202020202020202020202020202020207D0D0A0D0A20202020202020202020202020202020636F72652E6C6F6728225265667265';
wwv_flow_imp.g_varchar2_table(76) := '736820636F6D706C657465222C2076616C756573293B0D0A0D0A2020202020202020202020207D20636174636820286529207B0D0A20202020202020202020202020202020636F72652E6572726F72282252656672657368206572726F72222C2065293B';
wwv_flow_imp.g_varchar2_table(77) := '0D0A2020202020202020202020207D0D0A20202020202020207D0D0A0D0A2020202020202020202F2A203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D0D0A2020202020202020202020496E697420526F77730D0A20202020202020203D';
wwv_flow_imp.g_varchar2_table(78) := '3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D202A2F0D0A202020202020202066756E6374696F6E20696E6974526F77732829207B0D0A0D0A202020202020202020202020747279207B0D0A20202020202020202020202020202020766172';
wwv_flow_imp.g_varchar2_table(79) := '206578697374696E67203D205B5D3B0D0A0D0A202020202020202020202020202020206966202868696464656E2E76616C756529207B0D0A20202020202020202020202020202020202020206578697374696E67203D20286D54797065203D3D3D20224A';
wwv_flow_imp.g_varchar2_table(80) := '22290D0A2020202020202020202020202020202020202020202020203F20636F72652E736166654A534F4E2868696464656E2E76616C75652C205B5D290D0A2020202020202020202020202020202020202020202020203A2068696464656E2E76616C75';
wwv_flow_imp.g_varchar2_table(81) := '652E73706C697428736570617261746F72293B0D0A202020202020202020202020202020207D0D0A0D0A20202020202020202020202020202020696620286578697374696E672E6C656E677468203E203029207B0D0A2020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(82) := '2020202020206578697374696E672E666F72456163682866756E6374696F6E202876616C29207B0D0A202020202020202020202020202020202020202020202020636F6E7461696E65722E617070656E644368696C6428637265617465526F772876616C';
wwv_flow_imp.g_varchar2_table(83) := '29293B0D0A20202020202020202020202020202020202020207D293B0D0A202020202020202020202020202020207D20656C7365207B0D0A2020202020202020202020202020202020202020666F7220287661722069203D20303B2069203C20696E6974';
wwv_flow_imp.g_varchar2_table(84) := '69616C436F756E743B20692B2B29207B0D0A202020202020202020202020202020202020202020202020636F6E7461696E65722E617070656E644368696C6428637265617465526F7728222229293B0D0A20202020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(85) := '207D0D0A202020202020202020202020202020207D0D0A0D0A202020202020202020202020202020207265667265736828293B0D0A0D0A20202020202020202020202020202020636F72652E6C6F672822496E697469616C697A6564222C206578697374';
wwv_flow_imp.g_varchar2_table(86) := '696E67293B0D0A0D0A2020202020202020202020207D20636174636820286529207B0D0A20202020202020202020202020202020636F72652E6572726F722822496E6974206572726F72222C2065293B0D0A2020202020202020202020207D0D0A202020';
wwv_flow_imp.g_varchar2_table(87) := '20202020207D0D0A0D0A20202020202020202F2A203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D0D0A2020202020202020202020496E69740D0A20202020202020203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D202A';
wwv_flow_imp.g_varchar2_table(88) := '2F0D0A2020202020202020696E6974526F777328293B0D0A202020207D0D0A0D0A2020202072657475726E207B0D0A2020202020202020696E69743A20696E69740D0A202020207D3B0D0A0D0A7D2928293B0D0A0D0A617065782E64746C5F72656F7264';
wwv_flow_imp.g_varchar2_table(89) := '6572203D202866756E6374696F6E202829207B0D0A0D0A2020202066756E6374696F6E20696E697428704974656D49642C206F7074696F6E7329207B0D0A0D0A202020202020202076617220636F7265203D20617065782E64796E616D6963436F72653B';
wwv_flow_imp.g_varchar2_table(90) := '0D0A2020202020202020636F72652E6465627567203D20286F7074696F6E732E6A734C6F67456E61626C6564203D3D3D20225922293B0D0A2020202020202020636F72652E6C6F672822494E4954222C20704974656D49642C206F7074696F6E73293B0D';
wwv_flow_imp.g_varchar2_table(91) := '0A0D0A202020202020202076617220636F6E7461696E6572203D20646F63756D656E742E676574456C656D656E744279496428704974656D4964202B20225F636F6E7461696E657222293B0D0A20202020202020207661722068696464656E203D20646F';
wwv_flow_imp.g_varchar2_table(92) := '63756D656E742E676574456C656D656E744279496428704974656D4964293B0D0A0D0A20202020202020206966202821636F6E7461696E6572207C7C202168696464656E29207B0D0A202020202020202020202020636F72652E6572726F722822436F6E';
wwv_flow_imp.g_varchar2_table(93) := '7461696E6572206F722068696464656E206E6F7420666F756E64222C20704974656D4964293B0D0A20202020202020202020202072657475726E3B0D0A20202020202020207D0D0A0D0A202020202020202068696464656E2E5F64746C5F6F7074696F6E';
wwv_flow_imp.g_varchar2_table(94) := '73203D206F7074696F6E733B0D0A0D0A202020202020202076617220736F727461626C65496E7374616E6365203D206E756C6C3B0D0A0D0A20202020202020202F2A203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D0D0A202020202020';
wwv_flow_imp.g_varchar2_table(95) := '202020202055492048656C706572730D0A20202020202020203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D202A2F0D0A0D0A202020202020202066756E6374696F6E2073686F774572726F72286D736729207B0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(96) := '20202020636F6E7461696E65722E696E6E657248544D4C203D20600D0A202020202020202020202020202020203C64697620636C6173733D22742D416C65727420742D416C6572742D2D64616E676572223E0D0A20202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(97) := '20202020247B6D7367207C7C20224572726F72206C6F6164696E672064617461227D0D0A202020202020202020202020202020203C2F6469763E0D0A202020202020202020202020603B0D0A20202020202020207D0D0A0D0A202020202020202066756E';
wwv_flow_imp.g_varchar2_table(98) := '6374696F6E2073686F77456D7074792829207B0D0A20202020202020202020202076617220656D707479203D20646F63756D656E742E637265617465456C656D656E74282264697622293B0D0A20202020202020202020202076617220656D7074795465';
wwv_flow_imp.g_varchar2_table(99) := '7874203D206F7074696F6E732E6E6F44617461466F756E64207C7C20224E6F206461746120666F756E64223B0D0A202020202020202020202020656D7074792E636C6173734E616D65203D2022742D416C65727420742D416C6572742D2D64656661756C';
wwv_flow_imp.g_varchar2_table(100) := '7449636F6E7320742D416C6572742D2D7761726E696E6720742D416C6572742D2D686F72697A6F6E74616C223B0D0A0D0A202020202020202020202020656D7074792E696E6E657248544D4C203D20600D0A202020202020202020202020202020203C64';
wwv_flow_imp.g_varchar2_table(101) := '697620636C6173733D22742D416C6572742D77726170223E0D0A20202020202020202020202020202020202020203C64697620636C6173733D22742D416C6572742D69636F6E223E0D0A2020202020202020202020202020202020202020202020203C73';
wwv_flow_imp.g_varchar2_table(102) := '70616E20636C6173733D22742D49636F6E2066612D696E666F2D636972636C65223E3C2F7370616E3E0D0A20202020202020202020202020202020202020203C2F6469763E0D0A20202020202020202020202020202020202020203C64697620636C6173';
wwv_flow_imp.g_varchar2_table(103) := '733D22742D416C6572742D636F6E74656E74223E0D0A2020202020202020202020202020202020202020202020203C64697620636C6173733D22742D416C6572742D626F6479223E0D0A2020202020202020202020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(104) := '2020247B656D707479546578747D0D0A2020202020202020202020202020202020202020202020203C2F6469763E0D0A20202020202020202020202020202020202020203C2F6469763E0D0A202020202020202020202020202020203C2F6469763E0D0A';
wwv_flow_imp.g_varchar2_table(105) := '202020202020202020202020603B0D0A202020202020202020202020636F6E7461696E65722E617070656E644368696C6428656D707479293B0D0A20202020202020207D0D0A0D0A20202020202020202F2A203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D';
wwv_flow_imp.g_varchar2_table(106) := '3D3D3D3D3D3D3D3D0D0A2020202020202020202020526F77204372656174696F6E0D0A20202020202020203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D202A2F0D0A0D0A202020202020202066756E6374696F6E20637265617465526F';
wwv_flow_imp.g_varchar2_table(107) := '77286F626A29207B0D0A0D0A202020202020202020202020747279207B0D0A0D0A2020202020202020202020202020202076617220726F77203D20646F63756D656E742E637265617465456C656D656E74282264697622293B0D0A202020202020202020';
wwv_flow_imp.g_varchar2_table(108) := '20202020202020726F772E636C6173734E616D65203D202264746C2D726F7720742D466F726D2D696E707574436F6E7461696E6572223B0D0A20202020202020202020202020202020726F772E646174617365742E6964203D206F626A2E69643B0D0A0D';
wwv_flow_imp.g_varchar2_table(109) := '0A202020202020202020202020202020207661722068616E646C65203D20646F63756D656E742E637265617465456C656D656E7428227370616E22293B0D0A2020202020202020202020202020202068616E646C652E636C6173734E616D65203D202266';
wwv_flow_imp.g_varchar2_table(110) := '612066612D626172732064746C2D68616E646C65223B0D0A0D0A2020202020202020202020202020202076617220696E707574203D20646F63756D656E742E637265617465456C656D656E742822696E70757422293B0D0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(111) := '20202020696E7075742E74797065203D202274657874223B0D0A20202020202020202020202020202020696E7075742E636C6173734E616D65203D2022746578745F6669656C6420617065782D6974656D2D74657874223B0D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(112) := '202020202020696E7075742E76616C7565203D206F626A2E6C6162656C207C7C2022223B0D0A20202020202020202020202020202020696E7075742E726561644F6E6C79203D20747275653B0D0A0D0A20202020202020202020202020202020726F772E';
wwv_flow_imp.g_varchar2_table(113) := '617070656E644368696C642868616E646C65293B0D0A20202020202020202020202020202020726F772E617070656E644368696C6428696E707574293B0D0A0D0A2020202020202020202020202020202072657475726E20726F773B0D0A0D0A20202020';
wwv_flow_imp.g_varchar2_table(114) := '20202020202020207D20636174636820286529207B0D0A20202020202020202020202020202020636F72652E6572726F722822637265617465526F77206661696C6564222C20652C206F626A293B0D0A2020202020202020202020202020202072657475';
wwv_flow_imp.g_varchar2_table(115) := '726E20646F63756D656E742E637265617465456C656D656E74282264697622293B0D0A2020202020202020202020207D0D0A20202020202020207D0D0A0D0A20202020202020202F2A203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D0D';
wwv_flow_imp.g_varchar2_table(116) := '0A202020202020202020202056616C7565730D0A20202020202020203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D202A2F0D0A202020202020202066756E6374696F6E2067657456616C7565732829207B0D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(117) := '2020747279207B0D0A2020202020202020202020202020202076617220726F7773203D20636F6E7461696E65722E717565727953656C6563746F72416C6C28222E64746C2D726F7722293B0D0A202020202020202020202020202020207661722076616C';
wwv_flow_imp.g_varchar2_table(118) := '756573203D205B5D3B0D0A0D0A20202020202020202020202020202020726F77732E666F72456163682866756E6374696F6E2028726F7729207B0D0A202020202020202020202020202020202020202076616C7565732E70757368287B0D0A2020202020';
wwv_flow_imp.g_varchar2_table(119) := '2020202020202020202020202020202020202069643A20726F772E646174617365742E69642C0D0A2020202020202020202020202020202020202020202020206C6162656C3A20726F772E717565727953656C6563746F722822696E70757422292E7661';
wwv_flow_imp.g_varchar2_table(120) := '6C75650D0A20202020202020202020202020202020202020207D293B0D0A202020202020202020202020202020207D293B0D0A0D0A2020202020202020202020202020202072657475726E2076616C7565733B0D0A0D0A2020202020202020202020207D';
wwv_flow_imp.g_varchar2_table(121) := '20636174636820286529207B0D0A20202020202020202020202020202020636F72652E6572726F72282267657456616C756573206661696C6564222C2065293B0D0A2020202020202020202020202020202072657475726E205B5D3B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(122) := '2020202020207D0D0A20202020202020207D0D0A0D0A202020202020202066756E6374696F6E2073657456616C75652876616C75657329207B0D0A202020202020202020202020747279207B0D0A20202020202020202020202020202020617065782E69';
wwv_flow_imp.g_varchar2_table(123) := '74656D28704974656D4964292E73657456616C7565284A534F4E2E737472696E676966792876616C75657329293B0D0A2020202020202020202020207D20636174636820286529207B0D0A20202020202020202020202020202020636F72652E6572726F';
wwv_flow_imp.g_varchar2_table(124) := '72282273657456616C7565206661696C6564222C2065293B0D0A2020202020202020202020207D0D0A20202020202020207D0D0A0D0A202020202020202066756E6374696F6E207265667265736856616C75652829207B0D0A2020202020202020202020';
wwv_flow_imp.g_varchar2_table(125) := '2073657456616C75652867657456616C7565732829293B0D0A20202020202020207D0D0A0D0A20202020202020202F2A203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D0D0A202020202020202020202052656E646572696E670D0A2020';
wwv_flow_imp.g_varchar2_table(126) := '2020202020203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D202A2F0D0A0D0A202020202020202066756E6374696F6E2072656E6465724C697374286461746129207B0D0A0D0A202020202020202020202020636F72652E6C6F67282252';
wwv_flow_imp.g_varchar2_table(127) := '656E646572206C697374222C2064617461293B0D0A0D0A202020202020202020202020636F6E7461696E65722E696E6E657248544D4C203D2022223B0D0A0D0A202020202020202020202020696620282164617461207C7C20646174612E6C656E677468';
wwv_flow_imp.g_varchar2_table(128) := '203D3D3D203029207B0D0A2020202020202020202020202020202073686F77456D70747928293B0D0A2020202020202020202020202020202073657456616C7565285B5D293B0D0A2020202020202020202020202020202072657475726E3B0D0A202020';
wwv_flow_imp.g_varchar2_table(129) := '2020202020202020207D0D0A0D0A202020202020202020202020747279207B0D0A20202020202020202020202020202020646174612E666F72456163682866756E6374696F6E20286F626A29207B0D0A2020202020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(130) := '636F6E7461696E65722E617070656E644368696C6428637265617465526F77286F626A29293B0D0A202020202020202020202020202020207D293B0D0A0D0A2020202020202020202020202020202073657456616C75652867657456616C756573282929';
wwv_flow_imp.g_varchar2_table(131) := '3B0D0A0D0A2020202020202020202020207D20636174636820286529207B0D0A20202020202020202020202020202020636F72652E6572726F72282272656E6465724C697374206661696C6564222C2065293B0D0A202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(132) := '2073686F774572726F7228293B0D0A2020202020202020202020207D0D0A20202020202020207D0D0A0D0A20202020202020202F2A203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D0D0A20202020202020202020204472616720262044';
wwv_flow_imp.g_varchar2_table(133) := '726F700D0A20202020202020203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D202A2F0D0A202020202020202066756E6374696F6E20656E61626C654472616744726F702829207B0D0A0D0A202020202020202020202020696620287479';
wwv_flow_imp.g_varchar2_table(134) := '70656F6620536F727461626C65203D3D3D2022756E646566696E65642229207B0D0A20202020202020202020202020202020636F72652E6572726F722822536F727461626C654A53206E6F74206C6F6164656422293B0D0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(135) := '2020202072657475726E3B0D0A2020202020202020202020207D0D0A0D0A20202020202020202020202069662028736F727461626C65496E7374616E6365292072657475726E3B0D0A0D0A202020202020202020202020747279207B0D0A0D0A20202020';
wwv_flow_imp.g_varchar2_table(136) := '202020202020202020202020736F727461626C65496E7374616E6365203D206E657720536F727461626C6528636F6E7461696E65722C207B0D0A2020202020202020202020202020202020202020616E696D6174696F6E3A203135302C0D0A2020202020';
wwv_flow_imp.g_varchar2_table(137) := '20202020202020202020202020202068616E646C653A20222E64746C2D68616E646C65222C0D0A202020202020202020202020202020202020202067686F7374436C6173733A202264746C2D647261672D67686F7374222C0D0A0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(138) := '2020202020202020202020206F6E456E643A2066756E6374696F6E202829207B0D0A0D0A2020202020202020202020202020202020202020202020207661722076616C756573203D2067657456616C75657328293B0D0A0D0A2020202020202020202020';
wwv_flow_imp.g_varchar2_table(139) := '2020202020202020202020202073657456616C75652876616C756573293B0D0A0D0A202020202020202020202020202020202020202020202020636F72652E747269676765724576656E742868696464656E2C2022726F775F72656F726465726564222C';
wwv_flow_imp.g_varchar2_table(140) := '207B0D0A2020202020202020202020202020202020202020202020202020202076616C7565733A2076616C7565732C0D0A202020202020202020202020202020202020202020202020202020206974656D3A20704974656D49640D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(141) := '202020202020202020202020202020207D293B0D0A20202020202020202020202020202020202020207D0D0A202020202020202020202020202020207D293B0D0A0D0A2020202020202020202020207D20636174636820286529207B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(142) := '20202020202020202020636F72652E6572726F722822536F727461626C6520696E6974206661696C6564222C2065293B0D0A2020202020202020202020207D0D0A20202020202020207D0D0A0D0A20202020202020202F2A203D3D3D3D3D3D3D3D3D3D3D';
wwv_flow_imp.g_varchar2_table(143) := '3D3D3D3D3D3D3D3D3D3D3D3D3D3D0D0A2020202020202020202020414A415820526566726573680D0A20202020202020203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D202A2F0D0A202020202020202066756E6374696F6E20616A6178';
wwv_flow_imp.g_varchar2_table(144) := '526566726573682829207B0D0A0D0A20202020202020202020202069662028216F7074696F6E732E616A61784964656E74696669657229207B0D0A20202020202020202020202020202020636F72652E6C6F6728224E6F20414A4158206964656E746966';
wwv_flow_imp.g_varchar2_table(145) := '6965722C20736B697070696E67207265667265736822293B0D0A2020202020202020202020202020202072657475726E3B0D0A2020202020202020202020207D0D0A0D0A202020202020202020202020636F72652E6C6F672822414A41582043414C4C22';
wwv_flow_imp.g_varchar2_table(146) := '2C206F7074696F6E73293B0D0A0D0A202020202020202020202020766172207370696E6E65723B0D0A0D0A202020202020202020202020747279207B0D0A202020202020202020202020202020207370696E6E6572203D20617065782E7574696C2E7368';
wwv_flow_imp.g_varchar2_table(147) := '6F775370696E6E657228636F6E7461696E6572293B0D0A20202020202020202020202020202020636F6E7461696E65722E7374796C652E706F696E7465724576656E7473203D20226E6F6E65223B0D0A20202020202020202020202020202020636F6E74';
wwv_flow_imp.g_varchar2_table(148) := '61696E65722E7374796C652E6F706163697479203D2022302E35223B0D0A2020202020202020202020207D20636174636820286529207B0D0A20202020202020202020202020202020636F72652E6572726F7228225370696E6E6572206661696C656422';
wwv_flow_imp.g_varchar2_table(149) := '2C2065293B0D0A2020202020202020202020207D0D0A0D0A202020202020202020202020617065782E7365727665722E706C7567696E280D0A202020202020202020202020202020206F7074696F6E732E616A61784964656E7469666965722C0D0A2020';
wwv_flow_imp.g_varchar2_table(150) := '20202020202020202020202020207B0D0A2020202020202020202020202020202020202020706167654974656D733A20286F7074696F6E732E706167654974656D73207C7C202222290D0A2020202020202020202020202020202020202020202020202E';
wwv_flow_imp.g_varchar2_table(151) := '73706C697428222C22290D0A2020202020202020202020202020202020202020202020202E6D61702866756E6374696F6E20286929207B2072657475726E20222322202B20692E7472696D28293B207D290D0A2020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(152) := '202020202020202E6A6F696E28222C22290D0A202020202020202020202020202020207D2C0D0A202020202020202020202020202020207B0D0A2020202020202020202020202020202020202020737563636573733A2066756E6374696F6E2028726573';
wwv_flow_imp.g_varchar2_table(153) := '29207B0D0A0D0A202020202020202020202020202020202020202020202020636F72652E6C6F672822414A41582053554343455353222C20726573293B0D0A0D0A202020202020202020202020202020202020202020202020747279207B0D0A0D0A2020';
wwv_flow_imp.g_varchar2_table(154) := '20202020202020202020202020202020202020202020202020207661722064617461203D20636F72652E736166654A534F4E287265732E646174612C205B5D293B0D0A0D0A2020202020202020202020202020202020202020202020202020202072656E';
wwv_flow_imp.g_varchar2_table(155) := '6465724C6973742864617461293B0D0A0D0A20202020202020202020202020202020202020202020202020202020636F72652E747269676765724576656E742868696464656E2C2022646174615F726566726573686564222C207B0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(156) := '20202020202020202020202020202020202020202020202020636F756E743A20646174612E6C656E6774682C0D0A20202020202020202020202020202020202020202020202020202020202020206974656D3A20704974656D49640D0A20202020202020';
wwv_flow_imp.g_varchar2_table(157) := '2020202020202020202020202020202020202020207D293B0D0A0D0A2020202020202020202020202020202020202020202020207D20636174636820286529207B0D0A20202020202020202020202020202020202020202020202020202020636F72652E';
wwv_flow_imp.g_varchar2_table(158) := '6572726F722822414A415820737563636573732070726F63657373696E67206661696C6564222C2065293B0D0A2020202020202020202020202020202020202020202020202020202073686F774572726F722822496E76616C6964206461746122293B0D';
wwv_flow_imp.g_varchar2_table(159) := '0A2020202020202020202020202020202020202020202020207D0D0A0D0A202020202020202020202020202020202020202020202020636C65616E757028293B0D0A20202020202020202020202020202020202020207D2C0D0A0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(160) := '2020202020202020202020206572726F723A2066756E6374696F6E202865727229207B0D0A0D0A202020202020202020202020202020202020202020202020636F72652E6572726F722822414A4158204552524F52222C20657272293B0D0A0D0A202020';
wwv_flow_imp.g_varchar2_table(161) := '20202020202020202020202020202020202020202073686F774572726F7228224661696C656420746F206C6F6164206461746122293B0D0A0D0A202020202020202020202020202020202020202020202020636C65616E757028293B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(162) := '20202020202020202020202020207D0D0A202020202020202020202020202020207D0D0A202020202020202020202020293B0D0A0D0A20202020202020202020202066756E6374696F6E20636C65616E75702829207B0D0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(163) := '20202020747279207B0D0A2020202020202020202020202020202020202020696620287370696E6E657229207370696E6E65722E72656D6F766528293B0D0A2020202020202020202020202020202020202020636F6E7461696E65722E7374796C652E70';
wwv_flow_imp.g_varchar2_table(164) := '6F696E7465724576656E7473203D20226175746F223B0D0A2020202020202020202020202020202020202020636F6E7461696E65722E7374796C652E6F706163697479203D202231223B0D0A202020202020202020202020202020207D20636174636820';
wwv_flow_imp.g_varchar2_table(165) := '286529207B0D0A2020202020202020202020202020202020202020636F72652E6572726F722822436C65616E7570206661696C6564222C2065293B0D0A202020202020202020202020202020207D0D0A2020202020202020202020207D0D0A2020202020';
wwv_flow_imp.g_varchar2_table(166) := '2020207D0D0A0D0A20202020202020202F2A203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D0D0A2020202020202020202020496E69740D0A20202020202020203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D202A2F0D';
wwv_flow_imp.g_varchar2_table(167) := '0A202020202020202066756E6374696F6E20696E6974526F77732829207B0D0A0D0A202020202020202020202020747279207B0D0A0D0A202020202020202020202020202020207661722064617461203D20636F72652E736166654A534F4E286F707469';
wwv_flow_imp.g_varchar2_table(168) := '6F6E732E736F75726365446174612C205B5D293B0D0A0D0A202020202020202020202020202020202F2F2066616C6C6261636B0D0A2020202020202020202020202020202069662028282164617461207C7C20646174612E6C656E677468203D3D3D2030';
wwv_flow_imp.g_varchar2_table(169) := '292026262068696464656E2E76616C756529207B0D0A202020202020202020202020202020202020202064617461203D20636F72652E736166654A534F4E2868696464656E2E76616C75652C205B5D293B0D0A202020202020202020202020202020207D';
wwv_flow_imp.g_varchar2_table(170) := '0D0A0D0A2020202020202020202020202020202072656E6465724C6973742864617461293B0D0A0D0A2020202020202020202020207D20636174636820286529207B0D0A20202020202020202020202020202020636F72652E6572726F722822696E6974';
wwv_flow_imp.g_varchar2_table(171) := '526F7773206661696C6564222C2065293B0D0A2020202020202020202020202020202073686F774572726F7228293B0D0A2020202020202020202020207D0D0A20202020202020207D0D0A0D0A2020202020202020696E6974526F777328293B0D0A2020';
wwv_flow_imp.g_varchar2_table(172) := '202020202020656E61626C654472616744726F7028293B0D0A0D0A202020202020202068696464656E2E5F64746C5F72656672657368203D20616A6178526566726573683B0D0A202020207D0D0A0D0A202020202F2A203D3D3D3D3D3D3D3D3D3D3D3D3D';
wwv_flow_imp.g_varchar2_table(173) := '3D3D3D3D3D3D3D3D3D3D3D3D0D0A202020202020205075626C6963204150490D0A202020203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D202A2F0D0A2020202072657475726E207B0D0A0D0A2020202020202020696E69743A20696E69';
wwv_flow_imp.g_varchar2_table(174) := '742C0D0A0D0A2020202020202020726566726573683A2066756E6374696F6E2028704974656D496429207B0D0A0D0A20202020202020202020202076617220656C203D20646F63756D656E742E676574456C656D656E744279496428704974656D496429';
wwv_flow_imp.g_varchar2_table(175) := '3B0D0A0D0A20202020202020202020202069662028656C20262620656C2E5F64746C5F7265667265736829207B0D0A20202020202020202020202020202020656C2E5F64746C5F7265667265736828293B0D0A2020202020202020202020207D20656C73';
wwv_flow_imp.g_varchar2_table(176) := '65207B0D0A20202020202020202020202020202020636F6E736F6C652E7761726E282244544C3A2072656672657368206E6F7420696E697469616C697A6564222C20704974656D4964293B0D0A2020202020202020202020207D0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(177) := '7D0D0A0D0A202020207D3B0D0A0D0A7D2928293B0D0A0D0A0D0A617065782E64796E616D6963436F7265203D207B0D0A0D0A2020202064656275673A20747275652C200D0A0D0A202020206C6F673A2066756E6374696F6E202829207B0D0A2020202020';
wwv_flow_imp.g_varchar2_table(178) := '20202069662028746869732E646562756729207B0D0A202020202020202020202020636F6E736F6C652E6C6F672E6170706C7928636F6E736F6C652C205B2244544C3A225D2E636F6E6361742841727261792E66726F6D28617267756D656E7473292929';
wwv_flow_imp.g_varchar2_table(179) := '3B0D0A20202020202020207D0D0A202020207D2C0D0A0D0A202020206572726F723A2066756E6374696F6E202829207B0D0A2020202020202020636F6E736F6C652E6572726F722E6170706C7928636F6E736F6C652C205B2244544C204552524F523A22';
wwv_flow_imp.g_varchar2_table(180) := '5D2E636F6E6361742841727261792E66726F6D28617267756D656E74732929293B0D0A202020207D2C0D0A0D0A202020206465626F756E63653A2066756E6374696F6E2028666E2C2064656C617929207B0D0A20202020202020206C65742074696D6572';
wwv_flow_imp.g_varchar2_table(181) := '3B0D0A202020202020202072657475726E2066756E6374696F6E202829207B0D0A202020202020202020202020636C65617254696D656F75742874696D6572293B0D0A20202020202020202020202074696D6572203D2073657454696D656F757428666E';
wwv_flow_imp.g_varchar2_table(182) := '2C2064656C6179293B0D0A20202020202020207D3B0D0A202020207D2C0D0A0D0A20202020747269676765724576656E743A2066756E6374696F6E2028656C2C206E616D652C206461746129207B0D0A2020202020202020747279207B0D0A2020202020';
wwv_flow_imp.g_varchar2_table(183) := '20202020202020617065782E6576656E742E7472696767657228656C2C206E616D652C2064617461207C7C207B7D293B0D0A20202020202020207D20636174636820286529207B0D0A202020202020202020202020746869732E6572726F722822457665';
wwv_flow_imp.g_varchar2_table(184) := '6E742074726967676572206661696C6564222C206E616D652C2065293B0D0A20202020202020207D0D0A202020207D2C0D0A0D0A20202020736166654A534F4E3A2066756E6374696F6E202876616C2C2066616C6C6261636B29207B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(185) := '2020747279207B0D0A20202020202020202020202072657475726E20747970656F662076616C203D3D3D2022737472696E6722203F204A534F4E2E70617273652876616C29203A2076616C3B0D0A20202020202020207D20636174636820286529207B0D';
wwv_flow_imp.g_varchar2_table(186) := '0A202020202020202020202020746869732E6572726F7228224A534F4E207061727365206661696C6564222C2076616C2C2065293B0D0A20202020202020202020202072657475726E2066616C6C6261636B207C7C205B5D3B0D0A20202020202020207D';
wwv_flow_imp.g_varchar2_table(187) := '0D0A202020207D2C0D0A2020202076616C696461746556616C75653A2066756E6374696F6E2876616C2C20765F747970652C20765F7265676578297B0D0A202020202020202069662028765F74797065203D3D3D2022452229207B0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(188) := '202020202072657475726E202F5E5B5E5C73405D2B405B5E5C73405D2B5C2E5B5E5C73405D2B242F2E746573742876616C293B0D0A20202020202020207D0D0A0D0A202020202020202069662028765F74797065203D3D3D2022502229207B0D0A202020';
wwv_flow_imp.g_varchar2_table(189) := '20202020202020202072657475726E202F5E5B302D392B5C2D5C735D2B242F2E746573742876616C293B0D0A20202020202020207D0D0A0D0A202020202020202069662028765F74797065203D3D3D2022522229207B0D0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(190) := '72657475726E206E65772052656745787028765F7265676578292E746573742876616C293B0D0A20202020202020207D0D0A0D0A202020202020202072657475726E20747275653B0D0A202020207D0D0A0D0A7D3B0D0A';
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(732968404113886224)
,p_plugin_id=>wwv_flow_imp.id(732552980942701141)
,p_file_name=>'pjs.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '2E64746C2D726F77207B646973706C61793A20666C65783B6761703A203670783B6D617267696E2D626F74746F6D3A203670783B616C69676E2D6974656D733A2063656E7465723B7D2E64746C2D6572726F727B626F726465722D636F6C6F723A207265';
wwv_flow_imp.g_varchar2_table(2) := '642021696D706F7274616E743B7D2E64746C2D6475706C696361746520696E7075747B6261636B67726F756E643A20626C75653B636F6C6F723A2077686974653B7D2E64746C2D68616E646C65207B637572736F723A20677261623B636F6C6F723A2023';
wwv_flow_imp.g_varchar2_table(3) := '3838383B7D2E64746C2D726F773A616374697665202E64746C2D68616E646C65207B637572736F723A206772616262696E673B7D2E64746C2D647261672D67686F7374207B6F7061636974793A20302E353B7D';
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(735120219931990403)
,p_plugin_id=>wwv_flow_imp.id(732552980942701141)
,p_file_name=>'pstyle.min.css'
,p_mime_type=>'text/css'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '2F2A2120536F727461626C6520312E31352E37202D204D4954207C206769743A2F2F6769746875622E636F6D2F536F727461626C654A532F536F727461626C652E676974202A2F0D0A2166756E6374696F6E28742C65297B226F626A656374223D3D7479';
wwv_flow_imp.g_varchar2_table(2) := '70656F66206578706F727473262622756E646566696E656422213D747970656F66206D6F64756C653F6D6F64756C652E6578706F7274733D6528293A2266756E6374696F6E223D3D747970656F6620646566696E652626646566696E652E616D643F6465';
wwv_flow_imp.g_varchar2_table(3) := '66696E652865293A28743D747C7C73656C66292E536F727461626C653D6528297D28746869732C66756E6374696F6E28297B2275736520737472696374223B66756E6374696F6E206F28742C65297B286E756C6C3D3D657C7C653E742E6C656E67746829';
wwv_flow_imp.g_varchar2_table(4) := '262628653D742E6C656E677468293B666F7228766172206E3D302C6F3D41727261792865293B6E3C653B6E2B2B296F5B6E5D3D745B6E5D3B72657475726E206F7D66756E6374696F6E206928742C652C6E297B72657475726E28653D66756E6374696F6E';
wwv_flow_imp.g_varchar2_table(5) := '2874297B743D66756E6374696F6E28742C65297B696628226F626A65637422213D747970656F6620747C7C21742972657475726E20743B766172206E3D745B53796D626F6C2E746F5072696D69746976655D3B696628766F696420303D3D3D6E29726574';
wwv_flow_imp.g_varchar2_table(6) := '75726E2822737472696E67223D3D3D653F537472696E673A4E756D626572292874293B653D6E2E63616C6C28742C657C7C2264656661756C7422293B696628226F626A65637422213D747970656F6620652972657475726E20653B7468726F77206E6577';
wwv_flow_imp.g_varchar2_table(7) := '20547970654572726F7228224040746F5072696D6974697665206D7573742072657475726E2061207072696D69746976652076616C75652E22297D28742C22737472696E6722293B72657475726E2273796D626F6C223D3D747970656F6620743F743A74';
wwv_flow_imp.g_varchar2_table(8) := '2B22227D28652929696E20743F4F626A6563742E646566696E6550726F706572747928742C652C7B76616C75653A6E2C656E756D657261626C653A21302C636F6E666967757261626C653A21302C7772697461626C653A21307D293A745B655D3D6E2C74';
wwv_flow_imp.g_varchar2_table(9) := '7D66756E6374696F6E206128297B72657475726E28613D4F626A6563742E61737369676E3F4F626A6563742E61737369676E2E62696E6428293A66756E6374696F6E2874297B666F722876617220653D313B653C617267756D656E74732E6C656E677468';
wwv_flow_imp.g_varchar2_table(10) := '3B652B2B297B766172206E2C6F3D617267756D656E74735B655D3B666F72286E20696E206F29217B7D2E6861734F776E50726F70657274792E63616C6C286F2C6E297C7C28745B6E5D3D6F5B6E5D297D72657475726E20747D292E6170706C79286E756C';
wwv_flow_imp.g_varchar2_table(11) := '6C2C617267756D656E7473297D66756E6374696F6E207228652C74297B766172206E2C6F3D4F626A6563742E6B6579732865293B72657475726E204F626A6563742E6765744F776E50726F706572747953796D626F6C732626286E3D4F626A6563742E67';
wwv_flow_imp.g_varchar2_table(12) := '65744F776E50726F706572747953796D626F6C732865292C742626286E3D6E2E66696C7465722866756E6374696F6E2874297B72657475726E204F626A6563742E6765744F776E50726F706572747944657363726970746F7228652C74292E656E756D65';
wwv_flow_imp.g_varchar2_table(13) := '7261626C657D29292C6F2E707573682E6170706C79286F2C6E29292C6F7D66756E6374696F6E20492865297B666F722876617220743D313B743C617267756D656E74732E6C656E6774683B742B2B297B766172206E3D6E756C6C213D617267756D656E74';
wwv_flow_imp.g_varchar2_table(14) := '735B745D3F617267756D656E74735B745D3A7B7D3B7425323F72284F626A656374286E292C2130292E666F72456163682866756E6374696F6E2874297B6928652C742C6E5B745D297D293A4F626A6563742E6765744F776E50726F706572747944657363';
wwv_flow_imp.g_varchar2_table(15) := '726970746F72733F4F626A6563742E646566696E6550726F7065727469657328652C4F626A6563742E6765744F776E50726F706572747944657363726970746F7273286E29293A72284F626A656374286E29292E666F72456163682866756E6374696F6E';
wwv_flow_imp.g_varchar2_table(16) := '2874297B4F626A6563742E646566696E6550726F706572747928652C742C4F626A6563742E6765744F776E50726F706572747944657363726970746F72286E2C7429297D297D72657475726E20657D66756E6374696F6E206C28742C65297B6966286E75';
wwv_flow_imp.g_varchar2_table(17) := '6C6C3D3D742972657475726E7B7D3B766172206E2C6F3D66756E6374696F6E28742C65297B6966286E756C6C3D3D742972657475726E7B7D3B766172206E2C6F3D7B7D3B666F72286E20696E2074296966287B7D2E6861734F776E50726F70657274792E';
wwv_flow_imp.g_varchar2_table(18) := '63616C6C28742C6E29297B6966282D31213D3D652E696E6465784F66286E2929636F6E74696E75653B6F5B6E5D3D745B6E5D7D72657475726E206F7D28742C65293B6966284F626A6563742E6765744F776E50726F706572747953796D626F6C7329666F';
wwv_flow_imp.g_varchar2_table(19) := '722876617220693D4F626A6563742E6765744F776E50726F706572747953796D626F6C732874292C723D303B723C692E6C656E6774683B722B2B296E3D695B725D2C2D313D3D3D652E696E6465784F66286E2926267B7D2E70726F70657274794973456E';
wwv_flow_imp.g_varchar2_table(20) := '756D657261626C652E63616C6C28742C6E292626286F5B6E5D3D745B6E5D293B72657475726E206F7D66756E6374696F6E20652874297B72657475726E2066756E6374696F6E2874297B69662841727261792E697341727261792874292972657475726E';
wwv_flow_imp.g_varchar2_table(21) := '206F2874297D2874297C7C66756E6374696F6E2874297B69662822756E646566696E656422213D747970656F662053796D626F6C26266E756C6C213D745B53796D626F6C2E6974657261746F725D7C7C6E756C6C213D745B2240406974657261746F7222';
wwv_flow_imp.g_varchar2_table(22) := '5D2972657475726E2041727261792E66726F6D2874297D2874297C7C66756E6374696F6E28742C65297B69662874297B69662822737472696E67223D3D747970656F6620742972657475726E206F28742C65293B766172206E3D7B7D2E746F537472696E';
wwv_flow_imp.g_varchar2_table(23) := '672E63616C6C2874292E736C69636528382C2D31293B72657475726E224D6170223D3D3D286E3D224F626A656374223D3D3D6E2626742E636F6E7374727563746F723F742E636F6E7374727563746F722E6E616D653A6E297C7C22536574223D3D3D6E3F';
wwv_flow_imp.g_varchar2_table(24) := '41727261792E66726F6D2874293A22417267756D656E7473223D3D3D6E7C7C2F5E283F3A55697C49296E74283F3A387C31367C333229283F3A436C616D706564293F4172726179242F2E74657374286E293F6F28742C65293A766F696420307D7D287429';
wwv_flow_imp.g_varchar2_table(25) := '7C7C66756E6374696F6E28297B7468726F77206E657720547970654572726F722822496E76616C696420617474656D707420746F20737072656164206E6F6E2D6974657261626C6520696E7374616E63652E5C6E496E206F7264657220746F2062652069';
wwv_flow_imp.g_varchar2_table(26) := '74657261626C652C206E6F6E2D6172726179206F626A65637473206D75737420686176652061205B53796D626F6C2E6974657261746F725D2829206D6574686F642E22297D28297D66756E6374696F6E20732874297B72657475726E28733D2266756E63';
wwv_flow_imp.g_varchar2_table(27) := '74696F6E223D3D747970656F662053796D626F6C26262273796D626F6C223D3D747970656F662053796D626F6C2E6974657261746F723F66756E6374696F6E2874297B72657475726E20747970656F6620747D3A66756E6374696F6E2874297B72657475';
wwv_flow_imp.g_varchar2_table(28) := '726E207426262266756E6374696F6E223D3D747970656F662053796D626F6C2626742E636F6E7374727563746F723D3D3D53796D626F6C262674213D3D53796D626F6C2E70726F746F747970653F2273796D626F6C223A747970656F6620747D29287429';
wwv_flow_imp.g_varchar2_table(29) := '7D66756E6374696F6E20742874297B69662822756E646566696E656422213D747970656F662077696E646F77262677696E646F772E6E6176696761746F722972657475726E21216E6176696761746F722E757365724167656E742E6D617463682874297D';
wwv_flow_imp.g_varchar2_table(30) := '76617220793D74282F283F3A54726964656E742E2A72765B203A5D3F31315C2E7C6D7369657C69656D6F62696C657C57696E646F77732050686F6E65292F69292C773D74282F456467652F69292C633D74282F66697265666F782F69292C753D74282F73';
wwv_flow_imp.g_varchar2_table(31) := '61666172692F692926262174282F6368726F6D652F692926262174282F616E64726F69642F69292C643D74282F69502861647C6F647C686F6E65292F69292C6E3D74282F6368726F6D652F6929262674282F616E64726F69642F69292C683D7B63617074';
wwv_flow_imp.g_varchar2_table(32) := '7572653A21312C706173736976653A21317D3B66756E6374696F6E206628742C652C6E297B742E6164644576656E744C697374656E657228652C6E2C2179262668297D66756E6374696F6E207028742C652C6E297B742E72656D6F76654576656E744C69';
wwv_flow_imp.g_varchar2_table(33) := '7374656E657228652C6E2C2179262668297D66756E6374696F6E206728742C65297B69662865262628223E223D3D3D655B305D262628653D652E737562737472696E67283129292C7429297472797B696628742E6D6174636865732972657475726E2074';
wwv_flow_imp.g_varchar2_table(34) := '2E6D6174636865732865293B696628742E6D734D61746368657353656C6563746F722972657475726E20742E6D734D61746368657353656C6563746F722865293B696628742E7765626B69744D61746368657353656C6563746F722972657475726E2074';
wwv_flow_imp.g_varchar2_table(35) := '2E7765626B69744D61746368657353656C6563746F722865297D63617463682874297B72657475726E7D7D66756E6374696F6E206D2874297B72657475726E20742E686F7374262674213D3D646F63756D656E742626742E686F73742E6E6F6465547970';
wwv_flow_imp.g_varchar2_table(36) := '652626742E686F7374213D3D743F742E686F73743A742E706172656E744E6F64657D66756E6374696F6E205028742C652C6E2C6F297B69662874297B6E3D6E7C7C646F63756D656E743B646F7B6966286E756C6C213D65262628223E22213D3D655B305D';
wwv_flow_imp.g_varchar2_table(37) := '7C7C742E706172656E744E6F64653D3D3D6E2926266728742C65297C7C6F2626743D3D3D6E2972657475726E20747D7768696C652874213D3D6E262628743D6D28742929297D72657475726E206E756C6C7D76617220762C623D2F5C732B2F673B66756E';
wwv_flow_imp.g_varchar2_table(38) := '6374696F6E206B28742C652C6E297B766172206F3B74262665262628742E636C6173734C6973743F742E636C6173734C6973745B6E3F22616464223A2272656D6F7665225D2865293A286F3D282220222B742E636C6173734E616D652B222022292E7265';
wwv_flow_imp.g_varchar2_table(39) := '706C61636528622C222022292E7265706C616365282220222B652B2220222C222022292C742E636C6173734E616D653D286F2B286E3F2220222B653A222229292E7265706C61636528622C2220222929297D66756E6374696F6E205228742C652C6E297B';
wwv_flow_imp.g_varchar2_table(40) := '766172206F3D742626742E7374796C653B6966286F297B696628766F696420303D3D3D6E2972657475726E20646F63756D656E742E64656661756C74566965772626646F63756D656E742E64656661756C74566965772E676574436F6D70757465645374';
wwv_flow_imp.g_varchar2_table(41) := '796C653F6E3D646F63756D656E742E64656661756C74566965772E676574436F6D70757465645374796C6528742C2222293A742E63757272656E745374796C652626286E3D742E63757272656E745374796C65292C766F696420303D3D3D653F6E3A6E5B';
wwv_flow_imp.g_varchar2_table(42) := '655D3B6F5B653D21286520696E206F7C7C2D31213D3D652E696E6465784F6628227765626B69742229293F222D7765626B69742D222B653A655D3D6E2B2822737472696E67223D3D747970656F66206E3F22223A22707822297D7D66756E6374696F6E20';
wwv_flow_imp.g_varchar2_table(43) := '4428742C65297B766172206E3D22223B69662822737472696E67223D3D747970656F662074296E3D743B656C736520646F7B766172206F3D5228742C227472616E73666F726D22297D7768696C65286F2626226E6F6E6522213D3D6F2626286E3D6F2B22';
wwv_flow_imp.g_varchar2_table(44) := '20222B6E292C2165262628743D742E706172656E744E6F646529293B76617220693D77696E646F772E444F4D4D61747269787C7C77696E646F772E5765624B69744353534D61747269787C7C77696E646F772E4353534D61747269787C7C77696E646F77';
wwv_flow_imp.g_varchar2_table(45) := '2E4D534353534D61747269783B72657475726E206926266E65772069286E297D66756E6374696F6E204528742C652C6E297B69662874297B766172206F3D742E676574456C656D656E747342795461674E616D652865292C693D302C723D6F2E6C656E67';
wwv_flow_imp.g_varchar2_table(46) := '74683B6966286E29666F72283B693C723B692B2B296E286F5B695D2C69293B72657475726E206F7D72657475726E5B5D7D66756E6374696F6E204F28297B76617220743D646F63756D656E742E7363726F6C6C696E67456C656D656E743B72657475726E';
wwv_flow_imp.g_varchar2_table(47) := '20747C7C646F63756D656E742E646F63756D656E74456C656D656E747D66756E6374696F6E205828742C652C6E2C6F2C69297B696628742E676574426F756E64696E67436C69656E74526563747C7C743D3D3D77696E646F77297B76617220722C612C6C';
wwv_flow_imp.g_varchar2_table(48) := '2C732C632C752C643D74213D3D77696E646F772626742E706172656E744E6F6465262674213D3D4F28293F28613D28723D742E676574426F756E64696E67436C69656E74526563742829292E746F702C6C3D722E6C6566742C733D722E626F74746F6D2C';
wwv_flow_imp.g_varchar2_table(49) := '633D722E72696768742C753D722E6865696768742C722E7769647468293A286C3D613D302C733D77696E646F772E696E6E65724865696768742C633D77696E646F772E696E6E657257696474682C753D77696E646F772E696E6E65724865696768742C77';
wwv_flow_imp.g_varchar2_table(50) := '696E646F772E696E6E65725769647468293B69662828657C7C6E29262674213D3D77696E646F77262628693D697C7C742E706172656E744E6F64652C21792929646F7B696628692626692E676574426F756E64696E67436C69656E745265637426262822';
wwv_flow_imp.g_varchar2_table(51) := '6E6F6E6522213D3D5228692C227472616E73666F726D22297C7C6E26262273746174696322213D3D5228692C22706F736974696F6E222929297B76617220683D692E676574426F756E64696E67436C69656E745265637428293B612D3D682E746F702B70';
wwv_flow_imp.g_varchar2_table(52) := '61727365496E74285228692C22626F726465722D746F702D77696474682229292C6C2D3D682E6C6566742B7061727365496E74285228692C22626F726465722D6C6566742D77696474682229292C733D612B722E6865696768742C633D6C2B722E776964';
wwv_flow_imp.g_varchar2_table(53) := '74683B627265616B7D7D7768696C6528693D692E706172656E744E6F6465293B72657475726E206F262674213D3D77696E646F772626286F3D28653D4428697C7C7429292626652E612C743D652626652E642C65262628733D28612F3D74292B28752F3D';
wwv_flow_imp.g_varchar2_table(54) := '74292C633D286C2F3D6F292B28642F3D6F2929292C7B746F703A612C6C6566743A6C2C626F74746F6D3A732C72696768743A632C77696474683A642C6865696768743A757D7D7D66756E6374696F6E205928742C652C6E297B666F7228766172206F3D4D';
wwv_flow_imp.g_varchar2_table(55) := '28742C2130292C693D582874295B655D3B6F3B297B76617220723D58286F295B6E5D3B696628212822746F70223D3D3D6E7C7C226C656674223D3D3D6E3F723C3D693A693C3D72292972657475726E206F3B6966286F3D3D3D4F282929627265616B3B6F';
wwv_flow_imp.g_varchar2_table(56) := '3D4D286F2C2131297D72657475726E21317D66756E6374696F6E204228742C652C6E2C6F297B666F722876617220693D302C723D302C613D742E6368696C6472656E3B723C612E6C656E6774683B297B696628226E6F6E6522213D3D615B725D2E737479';
wwv_flow_imp.g_varchar2_table(57) := '6C652E646973706C61792626615B725D213D3D48742E67686F73742626286F7C7C615B725D213D3D48742E647261676765642926265028615B725D2C6E2E647261676761626C652C742C213129297B696628693D3D3D652972657475726E20615B725D3B';
wwv_flow_imp.g_varchar2_table(58) := '692B2B7D722B2B7D72657475726E206E756C6C7D66756E6374696F6E204628742C65297B666F7228766172206E3D742E6C617374456C656D656E744368696C643B6E2626286E3D3D3D48742E67686F73747C7C226E6F6E65223D3D3D52286E2C22646973';
wwv_flow_imp.g_varchar2_table(59) := '706C617922297C7C6526262167286E2C6529293B296E3D6E2E70726576696F7573456C656D656E745369626C696E673B72657475726E206E7C7C6E756C6C7D66756E6374696F6E206A28742C65297B766172206E3D303B69662821747C7C21742E706172';
wwv_flow_imp.g_varchar2_table(60) := '656E744E6F64652972657475726E2D313B666F72283B743D742E70726576696F7573456C656D656E745369626C696E673B292254454D504C415445223D3D3D742E6E6F64654E616D652E746F55707065724361736528297C7C743D3D3D48742E636C6F6E';
wwv_flow_imp.g_varchar2_table(61) := '657C7C652626216728742C65297C7C6E2B2B3B72657475726E206E7D66756E6374696F6E20532874297B76617220653D302C6E3D302C6F3D4F28293B6966287429646F7B76617220693D442874292C723D692E612C693D692E647D7768696C6528652B3D';
wwv_flow_imp.g_varchar2_table(62) := '742E7363726F6C6C4C6566742A722C6E2B3D742E7363726F6C6C546F702A692C74213D3D6F262628743D742E706172656E744E6F646529293B72657475726E5B652C6E5D7D66756E6374696F6E204D28742C65297B69662821747C7C21742E676574426F';
wwv_flow_imp.g_varchar2_table(63) := '756E64696E67436C69656E74526563742972657475726E204F28293B766172206E3D742C6F3D21313B646F7B6966286E2E636C69656E7457696474683C6E2E7363726F6C6C57696474687C7C6E2E636C69656E744865696768743C6E2E7363726F6C6C48';
wwv_flow_imp.g_varchar2_table(64) := '6569676874297B76617220693D52286E293B6966286E2E636C69656E7457696474683C6E2E7363726F6C6C5769647468262628226175746F223D3D692E6F766572666C6F77587C7C227363726F6C6C223D3D692E6F766572666C6F7758297C7C6E2E636C';
wwv_flow_imp.g_varchar2_table(65) := '69656E744865696768743C6E2E7363726F6C6C486569676874262628226175746F223D3D692E6F766572666C6F77597C7C227363726F6C6C223D3D692E6F766572666C6F775929297B696628216E2E676574426F756E64696E67436C69656E7452656374';
wwv_flow_imp.g_varchar2_table(66) := '7C7C6E3D3D3D646F63756D656E742E626F64792972657475726E204F28293B6966286F7C7C652972657475726E206E3B6F3D21307D7D7D7768696C65286E3D6E2E706172656E744E6F6465293B72657475726E204F28297D66756E6374696F6E205F2874';
wwv_flow_imp.g_varchar2_table(67) := '2C65297B72657475726E204D6174682E726F756E6428742E746F70293D3D3D4D6174682E726F756E6428652E746F702926264D6174682E726F756E6428742E6C656674293D3D3D4D6174682E726F756E6428652E6C6566742926264D6174682E726F756E';
wwv_flow_imp.g_varchar2_table(68) := '6428742E686569676874293D3D3D4D6174682E726F756E6428652E6865696768742926264D6174682E726F756E6428742E7769647468293D3D3D4D6174682E726F756E6428652E7769647468297D66756E6374696F6E204328652C6E297B72657475726E';
wwv_flow_imp.g_varchar2_table(69) := '2066756E6374696F6E28297B76617220743B767C7C28313D3D3D28743D617267756D656E7473292E6C656E6774683F652E63616C6C28746869732C745B305D293A652E6170706C7928746869732C74292C763D73657454696D656F75742866756E637469';
wwv_flow_imp.g_varchar2_table(70) := '6F6E28297B763D766F696420307D2C6E29297D7D66756E6374696F6E204828742C652C6E297B742E7363726F6C6C4C6566742B3D652C742E7363726F6C6C546F702B3D6E7D66756E6374696F6E20542874297B76617220653D77696E646F772E506F6C79';
wwv_flow_imp.g_varchar2_table(71) := '6D65722C6E3D77696E646F772E6A51756572797C7C77696E646F772E5A6570746F3B72657475726E20652626652E646F6D3F652E646F6D2874292E636C6F6E654E6F6465282130293A6E3F6E2874292E636C6F6E65282130295B305D3A742E636C6F6E65';
wwv_flow_imp.g_varchar2_table(72) := '4E6F6465282130297D66756E6374696F6E207828742C65297B5228742C22706F736974696F6E222C226162736F6C75746522292C5228742C22746F70222C652E746F70292C5228742C226C656674222C652E6C656674292C5228742C227769647468222C';
wwv_flow_imp.g_varchar2_table(73) := '652E7769647468292C5228742C22686569676874222C652E686569676874297D66756E6374696F6E20412874297B5228742C22706F736974696F6E222C2222292C5228742C22746F70222C2222292C5228742C226C656674222C2222292C5228742C2277';
wwv_flow_imp.g_varchar2_table(74) := '69647468222C2222292C5228742C22686569676874222C2222297D66756E6374696F6E204C286E2C6F2C69297B76617220723D7B7D3B72657475726E2041727261792E66726F6D286E2E6368696C6472656E292E666F72456163682866756E6374696F6E';
wwv_flow_imp.g_varchar2_table(75) := '2874297B76617220653B5028742C6F2E647261676761626C652C6E2C213129262621742E616E696D61746564262674213D3D69262628653D582874292C722E6C6566743D4D6174682E6D696E286E756C6C213D3D28743D722E6C656674292626766F6964';
wwv_flow_imp.g_varchar2_table(76) := '2030213D3D743F743A312F302C652E6C656674292C722E746F703D4D6174682E6D696E286E756C6C213D3D28743D722E746F70292626766F69642030213D3D743F743A312F302C652E746F70292C722E72696768743D4D6174682E6D6178286E756C6C21';
wwv_flow_imp.g_varchar2_table(77) := '3D3D28743D722E7269676874292626766F69642030213D3D743F743A2D312F302C652E7269676874292C722E626F74746F6D3D4D6174682E6D6178286E756C6C213D3D28743D722E626F74746F6D292626766F69642030213D3D743F743A2D312F302C65';
wwv_flow_imp.g_varchar2_table(78) := '2E626F74746F6D29297D292C722E77696474683D722E72696768742D722E6C6566742C722E6865696768743D722E626F74746F6D2D722E746F702C722E783D722E6C6566742C722E793D722E746F702C727D766172204B3D22536F727461626C65222B28';
wwv_flow_imp.g_varchar2_table(79) := '6E65772044617465292E67657454696D6528293B66756E6374696F6E204E28297B76617220652C6F3D5B5D3B72657475726E7B63617074757265416E696D6174696F6E53746174653A66756E6374696F6E28297B6F3D5B5D2C746869732E6F7074696F6E';
wwv_flow_imp.g_varchar2_table(80) := '732E616E696D6174696F6E26265B5D2E736C6963652E63616C6C28746869732E656C2E6368696C6472656E292E666F72456163682866756E6374696F6E2874297B76617220652C6E3B226E6F6E6522213D3D5228742C22646973706C6179222926267421';
wwv_flow_imp.g_varchar2_table(81) := '3D3D48742E67686F73742626286F2E70757368287B7461726765743A742C726563743A582874297D292C653D49287B7D2C6F5B6F2E6C656E6774682D315D2E72656374292C21742E74686973416E696D6174696F6E4475726174696F6E7C7C286E3D4428';
wwv_flow_imp.g_varchar2_table(82) := '742C21302929262628652E746F702D3D6E2E662C652E6C6566742D3D6E2E65292C742E66726F6D526563743D65297D297D2C616464416E696D6174696F6E53746174653A66756E6374696F6E2874297B6F2E707573682874297D2C72656D6F7665416E69';
wwv_flow_imp.g_varchar2_table(83) := '6D6174696F6E53746174653A66756E6374696F6E2874297B6F2E73706C6963652866756E6374696F6E28742C65297B666F7228766172206E20696E207429696628742E6861734F776E50726F7065727479286E2929666F7228766172206F20696E206529';
wwv_flow_imp.g_varchar2_table(84) := '696628652E6861734F776E50726F7065727479286F292626655B6F5D3D3D3D745B6E5D5B6F5D2972657475726E204E756D626572286E293B72657475726E2D317D286F2C7B7461726765743A747D292C31297D2C616E696D617465416C6C3A66756E6374';
wwv_flow_imp.g_varchar2_table(85) := '696F6E2874297B76617220633D746869733B69662821746869732E6F7074696F6E732E616E696D6174696F6E2972657475726E20636C65617254696D656F75742865292C766F6964282266756E6374696F6E223D3D747970656F6620742626742829293B';
wwv_flow_imp.g_varchar2_table(86) := '76617220753D21312C643D303B6F2E666F72456163682866756E6374696F6E2874297B76617220653D302C6E3D742E7461726765742C6F3D6E2E66726F6D526563742C693D58286E292C723D6E2E7072657646726F6D526563742C613D6E2E7072657654';
wwv_flow_imp.g_varchar2_table(87) := '6F526563742C6C3D742E726563742C733D44286E2C2130293B73262628692E746F702D3D732E662C692E6C6566742D3D732E65292C6E2E746F526563743D692C6E2E74686973416E696D6174696F6E4475726174696F6E26265F28722C69292626215F28';
wwv_flow_imp.g_varchar2_table(88) := '6F2C69292626286C2E746F702D692E746F70292F286C2E6C6566742D692E6C656674293D3D286F2E746F702D692E746F70292F286F2E6C6566742D692E6C65667429262628743D6C2C733D722C723D612C613D632E6F7074696F6E732C653D4D6174682E';
wwv_flow_imp.g_varchar2_table(89) := '73717274284D6174682E706F7728732E746F702D742E746F702C32292B4D6174682E706F7728732E6C6566742D742E6C6566742C3229292F4D6174682E73717274284D6174682E706F7728732E746F702D722E746F702C32292B4D6174682E706F772873';
wwv_flow_imp.g_varchar2_table(90) := '2E6C6566742D722E6C6566742C3229292A612E616E696D6174696F6E292C5F28692C6F297C7C286E2E7072657646726F6D526563743D6F2C6E2E70726576546F526563743D692C653D657C7C632E6F7074696F6E732E616E696D6174696F6E2C632E616E';
wwv_flow_imp.g_varchar2_table(91) := '696D617465286E2C6C2C692C6529292C65262628753D21302C643D4D6174682E6D617828642C65292C636C65617254696D656F7574286E2E616E696D6174696F6E526573657454696D6572292C6E2E616E696D6174696F6E526573657454696D65723D73';
wwv_flow_imp.g_varchar2_table(92) := '657454696D656F75742866756E6374696F6E28297B6E2E616E696D6174696F6E54696D653D302C6E2E7072657646726F6D526563743D6E756C6C2C6E2E66726F6D526563743D6E756C6C2C6E2E70726576546F526563743D6E756C6C2C6E2E7468697341';
wwv_flow_imp.g_varchar2_table(93) := '6E696D6174696F6E4475726174696F6E3D6E756C6C7D2C65292C6E2E74686973416E696D6174696F6E4475726174696F6E3D65297D292C636C65617254696D656F75742865292C753F653D73657454696D656F75742866756E6374696F6E28297B226675';
wwv_flow_imp.g_varchar2_table(94) := '6E6374696F6E223D3D747970656F66207426267428297D2C64293A2266756E6374696F6E223D3D747970656F66207426267428292C6F3D5B5D7D2C616E696D6174653A66756E6374696F6E28742C652C6E2C6F297B76617220692C723B6F262628522874';
wwv_flow_imp.g_varchar2_table(95) := '2C227472616E736974696F6E222C2222292C5228742C227472616E73666F726D222C2222292C693D28723D4428746869732E656C29292626722E612C723D722626722E642C693D28652E6C6566742D6E2E6C656674292F28697C7C31292C723D28652E74';
wwv_flow_imp.g_varchar2_table(96) := '6F702D6E2E746F70292F28727C7C31292C742E616E696D6174696E67583D2121692C742E616E696D6174696E67593D2121722C5228742C227472616E73666F726D222C227472616E736C617465336428222B692B2270782C222B722B2270782C30292229';
wwv_flow_imp.g_varchar2_table(97) := '2C746869732E666F7252657061696E7444756D6D793D742E6F666673657457696474682C5228742C227472616E736974696F6E222C227472616E73666F726D20222B6F2B226D73222B28746869732E6F7074696F6E732E656173696E673F2220222B7468';
wwv_flow_imp.g_varchar2_table(98) := '69732E6F7074696F6E732E656173696E673A222229292C5228742C227472616E73666F726D222C227472616E736C617465336428302C302C302922292C226E756D626572223D3D747970656F6620742E616E696D617465642626636C65617254696D656F';
wwv_flow_imp.g_varchar2_table(99) := '757428742E616E696D61746564292C742E616E696D617465643D73657454696D656F75742866756E6374696F6E28297B5228742C227472616E736974696F6E222C2222292C5228742C227472616E73666F726D222C2222292C742E616E696D617465643D';
wwv_flow_imp.g_varchar2_table(100) := '21312C742E616E696D6174696E67583D21312C742E616E696D6174696E67593D21317D2C6F29297D7D7D76617220573D5B5D2C7A3D7B696E697469616C697A65427944656661756C743A21307D2C473D7B6D6F756E743A66756E6374696F6E2865297B66';
wwv_flow_imp.g_varchar2_table(101) := '6F7228766172207420696E207A29217A2E6861734F776E50726F70657274792874297C7C7420696E20657C7C28655B745D3D7A5B745D293B572E666F72456163682866756E6374696F6E2874297B696628742E706C7567696E4E616D653D3D3D652E706C';
wwv_flow_imp.g_varchar2_table(102) := '7567696E4E616D65297468726F7722536F727461626C653A2043616E6E6F74206D6F756E7420706C7567696E20222E636F6E63617428652E706C7567696E4E616D652C22206D6F7265207468616E206F6E636522297D292C572E707573682865297D2C70';
wwv_flow_imp.g_varchar2_table(103) := '6C7567696E4576656E743A66756E6374696F6E28652C6E2C6F297B76617220743D746869733B746869732E6576656E7443616E63656C65643D21312C6F2E63616E63656C3D66756E6374696F6E28297B742E6576656E7443616E63656C65643D21307D3B';
wwv_flow_imp.g_varchar2_table(104) := '76617220693D652B22476C6F62616C223B572E666F72456163682866756E6374696F6E2874297B6E5B742E706C7567696E4E616D655D2626286E5B742E706C7567696E4E616D655D5B695D26266E5B742E706C7567696E4E616D655D5B695D2849287B73';
wwv_flow_imp.g_varchar2_table(105) := '6F727461626C653A6E7D2C6F29292C6E2E6F7074696F6E735B742E706C7567696E4E616D655D26266E5B742E706C7567696E4E616D655D5B655D26266E5B742E706C7567696E4E616D655D5B655D2849287B736F727461626C653A6E7D2C6F2929297D29';
wwv_flow_imp.g_varchar2_table(106) := '7D2C696E697469616C697A65506C7567696E733A66756E6374696F6E286E2C6F2C692C74297B666F7228766172206520696E20572E666F72456163682866756E6374696F6E2874297B76617220653D742E706C7567696E4E616D653B286E2E6F7074696F';
wwv_flow_imp.g_varchar2_table(107) := '6E735B655D7C7C742E696E697469616C697A65427944656661756C742926262828743D6E65772074286E2C6F2C6E2E6F7074696F6E7329292E736F727461626C653D6E2C742E6F7074696F6E733D6E2E6F7074696F6E732C6E5B655D3D742C6128692C74';
wwv_flow_imp.g_varchar2_table(108) := '2E64656661756C747329297D292C6E2E6F7074696F6E73297B76617220723B6E2E6F7074696F6E732E6861734F776E50726F7065727479286529262628766F69642030213D3D28723D746869732E6D6F646966794F7074696F6E286E2C652C6E2E6F7074';
wwv_flow_imp.g_varchar2_table(109) := '696F6E735B655D29292626286E2E6F7074696F6E735B655D3D7229297D7D2C6765744576656E7450726F706572746965733A66756E6374696F6E28652C6E297B766172206F3D7B7D3B72657475726E20572E666F72456163682866756E6374696F6E2874';
wwv_flow_imp.g_varchar2_table(110) := '297B2266756E6374696F6E223D3D747970656F6620742E6576656E7450726F70657274696573262661286F2C742E6576656E7450726F706572746965732E63616C6C286E5B742E706C7567696E4E616D655D2C6529297D292C6F7D2C6D6F646966794F70';
wwv_flow_imp.g_varchar2_table(111) := '74696F6E3A66756E6374696F6E28652C6E2C6F297B76617220693B72657475726E20572E666F72456163682866756E6374696F6E2874297B655B742E706C7567696E4E616D655D2626742E6F7074696F6E4C697374656E65727326262266756E6374696F';
wwv_flow_imp.g_varchar2_table(112) := '6E223D3D747970656F6620742E6F7074696F6E4C697374656E6572735B6E5D262628693D742E6F7074696F6E4C697374656E6572735B6E5D2E63616C6C28655B742E706C7567696E4E616D655D2C6F29297D292C697D7D3B66756E6374696F6E20552874';
wwv_flow_imp.g_varchar2_table(113) := '297B76617220653D742E736F727461626C652C6E3D742E726F6F74456C2C6F3D742E6E616D652C693D742E746172676574456C2C723D742E636C6F6E65456C2C613D742E746F456C2C6C3D742E66726F6D456C2C733D742E6F6C64496E6465782C633D74';
wwv_flow_imp.g_varchar2_table(114) := '2E6E6577496E6465782C753D742E6F6C64447261676761626C65496E6465782C643D742E6E6577447261676761626C65496E6465782C683D742E6F726967696E616C4576656E742C663D742E707574536F727461626C652C703D742E6578747261457665';
wwv_flow_imp.g_varchar2_table(115) := '6E7450726F706572746965733B696628653D657C7C6E26266E5B4B5D297B76617220672C6D3D652E6F7074696F6E732C743D226F6E222B6F2E6368617241742830292E746F55707065724361736528292B6F2E7375627374722831293B2177696E646F77';
wwv_flow_imp.g_varchar2_table(116) := '2E437573746F6D4576656E747C7C797C7C773F28673D646F63756D656E742E6372656174654576656E7428224576656E742229292E696E69744576656E74286F2C21302C2130293A673D6E657720437573746F6D4576656E74286F2C7B627562626C6573';
wwv_flow_imp.g_varchar2_table(117) := '3A21302C63616E63656C61626C653A21307D292C672E746F3D617C7C6E2C672E66726F6D3D6C7C7C6E2C672E6974656D3D697C7C6E2C672E636C6F6E653D722C672E6F6C64496E6465783D732C672E6E6577496E6465783D632C672E6F6C644472616767';
wwv_flow_imp.g_varchar2_table(118) := '61626C65496E6465783D752C672E6E6577447261676761626C65496E6465783D642C672E6F726967696E616C4576656E743D682C672E70756C6C4D6F64653D663F662E6C6173745075744D6F64653A766F696420303B76617220762C623D492849287B7D';
wwv_flow_imp.g_varchar2_table(119) := '2C70292C472E6765744576656E7450726F70657274696573286F2C6529293B666F72287620696E206229675B765D3D625B765D3B6E26266E2E64697370617463684576656E742867292C6D5B745D26266D5B745D2E63616C6C28652C67297D7D66756E63';
wwv_flow_imp.g_varchar2_table(120) := '74696F6E207128742C65297B766172206E3D286F3D323C617267756D656E74732E6C656E6774682626766F69642030213D3D617267756D656E74735B325D3F617267756D656E74735B325D3A7B7D292E6576742C6F3D6C286F2C56293B472E706C756769';
wwv_flow_imp.g_varchar2_table(121) := '6E4576656E742E62696E642848742928742C652C49287B64726167456C3A242C706172656E74456C3A512C67686F7374456C3A4A2C726F6F74456C3A74742C6E657874456C3A65742C6C617374446F776E456C3A6E742C636C6F6E65456C3A6F742C636C';
wwv_flow_imp.g_varchar2_table(122) := '6F6E6548696464656E3A69742C64726167537461727465643A76742C707574536F727461626C653A75742C616374697665536F727461626C653A48742E6163746976652C6F726967696E616C4576656E743A6E2C6F6C64496E6465783A72742C6F6C6444';
wwv_flow_imp.g_varchar2_table(123) := '7261676761626C65496E6465783A6C742C6E6577496E6465783A61742C6E6577447261676761626C65496E6465783A73742C6869646547686F7374466F725461726765743A59742C756E6869646547686F7374466F725461726765743A42742C636C6F6E';
wwv_flow_imp.g_varchar2_table(124) := '654E6F7748696464656E3A66756E6374696F6E28297B69743D21307D2C636C6F6E654E6F7753686F776E3A66756E6374696F6E28297B69743D21317D2C6469737061746368536F727461626C654576656E743A66756E6374696F6E2874297B5A287B736F';
wwv_flow_imp.g_varchar2_table(125) := '727461626C653A652C6E616D653A742C6F726967696E616C4576656E743A6E7D297D7D2C6F29297D76617220563D5B22657674225D3B66756E6374696F6E205A2874297B552849287B707574536F727461626C653A75742C636C6F6E65456C3A6F742C74';
wwv_flow_imp.g_varchar2_table(126) := '6172676574456C3A242C726F6F74456C3A74742C6F6C64496E6465783A72742C6F6C64447261676761626C65496E6465783A6C742C6E6577496E6465783A61742C6E6577447261676761626C65496E6465783A73747D2C7429297D76617220242C512C4A';
wwv_flow_imp.g_varchar2_table(127) := '2C74742C65742C6E742C6F742C69742C72742C61742C6C742C73742C63742C75742C64742C68742C66742C70742C67742C6D742C76742C62742C79742C77742C44742C45743D21312C53743D21312C5F743D5B5D2C43743D21312C54743D21312C78743D';
wwv_flow_imp.g_varchar2_table(128) := '5B5D2C4F743D21312C4D743D5B5D2C41743D22756E646566696E656422213D747970656F6620646F63756D656E742C4E743D642C49743D777C7C793F22637373466C6F6174223A22666C6F6174222C50743D41742626216E262621642626226472616767';
wwv_flow_imp.g_varchar2_table(129) := '61626C6522696E20646F63756D656E742E637265617465456C656D656E74282264697622292C6B743D66756E6374696F6E28297B6966284174297B696628792972657475726E21313B76617220743D646F63756D656E742E637265617465456C656D656E';
wwv_flow_imp.g_varchar2_table(130) := '7428227822293B72657475726E20742E7374796C652E637373546578743D22706F696E7465722D6576656E74733A6175746F222C226175746F223D3D3D742E7374796C652E706F696E7465724576656E74737D7D28292C52743D66756E6374696F6E2874';
wwv_flow_imp.g_varchar2_table(131) := '2C65297B766172206E3D522874292C6F3D7061727365496E74286E2E7769647468292D7061727365496E74286E2E70616464696E674C656674292D7061727365496E74286E2E70616464696E675269676874292D7061727365496E74286E2E626F726465';
wwv_flow_imp.g_varchar2_table(132) := '724C6566745769647468292D7061727365496E74286E2E626F7264657252696768745769647468292C693D4228742C302C65292C723D4228742C312C65292C613D692626522869292C6C3D722626522872292C733D6126267061727365496E7428612E6D';
wwv_flow_imp.g_varchar2_table(133) := '617267696E4C656674292B7061727365496E7428612E6D617267696E5269676874292B582869292E77696474682C743D6C26267061727365496E74286C2E6D617267696E4C656674292B7061727365496E74286C2E6D617267696E5269676874292B5828';
wwv_flow_imp.g_varchar2_table(134) := '72292E77696474683B69662822666C6578223D3D3D6E2E646973706C61792972657475726E22636F6C756D6E223D3D3D6E2E666C6578446972656374696F6E7C7C22636F6C756D6E2D72657665727365223D3D3D6E2E666C6578446972656374696F6E3F';
wwv_flow_imp.g_varchar2_table(135) := '22766572746963616C223A22686F72697A6F6E74616C223B6966282267726964223D3D3D6E2E646973706C61792972657475726E206E2E6772696454656D706C617465436F6C756D6E732E73706C697428222022292E6C656E6774683C3D313F22766572';
wwv_flow_imp.g_varchar2_table(136) := '746963616C223A22686F72697A6F6E74616C223B696628692626612E666C6F61742626226E6F6E6522213D3D612E666C6F6174297B653D226C656674223D3D3D612E666C6F61743F226C656674223A227269676874223B72657475726E21727C7C22626F';
wwv_flow_imp.g_varchar2_table(137) := '746822213D3D6C2E636C65617226266C2E636C656172213D3D653F22686F72697A6F6E74616C223A22766572746963616C227D72657475726E206926262822626C6F636B223D3D3D612E646973706C61797C7C22666C6578223D3D3D612E646973706C61';
wwv_flow_imp.g_varchar2_table(138) := '797C7C227461626C65223D3D3D612E646973706C61797C7C2267726964223D3D3D612E646973706C61797C7C6F3C3D732626226E6F6E65223D3D3D6E5B49745D7C7C722626226E6F6E65223D3D3D6E5B49745D26266F3C732B74293F2276657274696361';
wwv_flow_imp.g_varchar2_table(139) := '6C223A22686F72697A6F6E74616C227D2C58743D66756E6374696F6E2874297B66756E6374696F6E206C28722C61297B72657475726E2066756E6374696F6E28742C652C6E2C6F297B76617220693D742E6F7074696F6E732E67726F75702E6E616D6526';
wwv_flow_imp.g_varchar2_table(140) := '26652E6F7074696F6E732E67726F75702E6E616D652626742E6F7074696F6E732E67726F75702E6E616D653D3D3D652E6F7074696F6E732E67726F75702E6E616D653B6966286E756C6C3D3D72262628617C7C69292972657475726E21303B6966286E75';
wwv_flow_imp.g_varchar2_table(141) := '6C6C3D3D727C7C21313D3D3D722972657475726E21313B69662861262622636C6F6E65223D3D3D722972657475726E20723B6966282266756E6374696F6E223D3D747970656F6620722972657475726E206C287228742C652C6E2C6F292C612928742C65';
wwv_flow_imp.g_varchar2_table(142) := '2C6E2C6F293B653D28613F743A65292E6F7074696F6E732E67726F75702E6E616D653B72657475726E21303D3D3D727C7C22737472696E67223D3D747970656F6620722626723D3D3D657C7C722E6A6F696E26262D313C722E696E6465784F662865297D';
wwv_flow_imp.g_varchar2_table(143) := '7D76617220653D7B7D2C6E3D742E67726F75703B6E2626226F626A656374223D3D73286E297C7C286E3D7B6E616D653A6E7D292C652E6E616D653D6E2E6E616D652C652E636865636B50756C6C3D6C286E2E70756C6C2C2130292C652E636865636B5075';
wwv_flow_imp.g_varchar2_table(144) := '743D6C286E2E707574292C652E726576657274436C6F6E653D6E2E726576657274436C6F6E652C742E67726F75703D657D2C59743D66756E6374696F6E28297B216B7426264A262652284A2C22646973706C6179222C226E6F6E6522297D2C42743D6675';
wwv_flow_imp.g_varchar2_table(145) := '6E6374696F6E28297B216B7426264A262652284A2C22646973706C6179222C2222297D3B41742626216E2626646F63756D656E742E6164644576656E744C697374656E65722822636C69636B222C66756E6374696F6E2874297B69662853742972657475';
wwv_flow_imp.g_varchar2_table(146) := '726E20742E70726576656E7444656661756C7428292C742E73746F7050726F7061676174696F6E2626742E73746F7050726F7061676174696F6E28292C742E73746F70496D6D65646961746550726F7061676174696F6E2626742E73746F70496D6D6564';
wwv_flow_imp.g_varchar2_table(147) := '6961746550726F7061676174696F6E28292C53743D21317D2C2130293B66756E6374696F6E2046742874297B69662824297B743D742E746F75636865733F742E746F75636865735B305D3A743B76617220653D28693D742E636C69656E74582C723D742E';
wwv_flow_imp.g_varchar2_table(148) := '636C69656E74592C5F742E736F6D652866756E6374696F6E2874297B76617220653D745B4B5D2E6F7074696F6E732E656D707479496E736572745468726573686F6C643B6966286526262146287429297B766172206E3D582874292C6F3D693E3D6E2E6C';
wwv_flow_imp.g_varchar2_table(149) := '6566742D652626693C3D6E2E72696768742B652C653D723E3D6E2E746F702D652626723C3D6E2E626F74746F6D2B653B72657475726E206F2626653F613D743A766F696420307D7D292C61293B69662865297B766172206E2C6F3D7B7D3B666F72286E20';
wwv_flow_imp.g_varchar2_table(150) := '696E207429742E6861734F776E50726F7065727479286E292626286F5B6E5D3D745B6E5D293B6F2E7461726765743D6F2E726F6F74456C3D652C6F2E70726576656E7444656661756C743D766F696420302C6F2E73746F7050726F7061676174696F6E3D';
wwv_flow_imp.g_varchar2_table(151) := '766F696420302C655B4B5D2E5F6F6E447261674F766572286F297D7D76617220692C722C617D66756E6374696F6E206A742874297B242626242E706172656E744E6F64655B4B5D2E5F69734F75747369646554686973456C28742E746172676574297D66';
wwv_flow_imp.g_varchar2_table(152) := '756E6374696F6E20487428742C65297B69662821747C7C21742E6E6F6465547970657C7C31213D3D742E6E6F646554797065297468726F7722536F727461626C653A2060656C60206D75737420626520616E2048544D4C456C656D656E742C206E6F7420';
wwv_flow_imp.g_varchar2_table(153) := '222E636F6E636174287B7D2E746F537472696E672E63616C6C287429293B746869732E656C3D742C746869732E6F7074696F6E733D653D61287B7D2C65292C745B4B5D3D746869733B766172206E2C6F2C693D7B67726F75703A6E756C6C2C736F72743A';
wwv_flow_imp.g_varchar2_table(154) := '21302C64697361626C65643A21312C73746F72653A6E756C6C2C68616E646C653A6E756C6C2C647261676761626C653A2F5E5B756F5D6C242F692E7465737428742E6E6F64654E616D65293F223E6C69223A223E2A222C737761705468726573686F6C64';
wwv_flow_imp.g_varchar2_table(155) := '3A312C696E76657274537761703A21312C696E766572746564537761705468726573686F6C643A6E756C6C2C72656D6F7665436C6F6E654F6E486964653A21302C646972656374696F6E3A66756E6374696F6E28297B72657475726E20527428742C7468';
wwv_flow_imp.g_varchar2_table(156) := '69732E6F7074696F6E73297D2C67686F7374436C6173733A22736F727461626C652D67686F7374222C63686F73656E436C6173733A22736F727461626C652D63686F73656E222C64726167436C6173733A22736F727461626C652D64726167222C69676E';
wwv_flow_imp.g_varchar2_table(157) := '6F72653A22612C20696D67222C66696C7465723A6E756C6C2C70726576656E744F6E46696C7465723A21302C616E696D6174696F6E3A302C656173696E673A6E756C6C2C736574446174613A66756E6374696F6E28742C65297B742E7365744461746128';
wwv_flow_imp.g_varchar2_table(158) := '2254657874222C652E74657874436F6E74656E74297D2C64726F70427562626C653A21312C647261676F766572427562626C653A21312C646174614964417474723A22646174612D6964222C64656C61793A302C64656C61794F6E546F7563684F6E6C79';
wwv_flow_imp.g_varchar2_table(159) := '3A21312C746F75636853746172745468726573686F6C643A284E756D6265722E7061727365496E743F4E756D6265723A77696E646F77292E7061727365496E742877696E646F772E646576696365506978656C526174696F2C3130297C7C312C666F7263';
wwv_flow_imp.g_varchar2_table(160) := '6546616C6C6261636B3A21312C66616C6C6261636B436C6173733A22736F727461626C652D66616C6C6261636B222C66616C6C6261636B4F6E426F64793A21312C66616C6C6261636B546F6C6572616E63653A302C66616C6C6261636B4F66667365743A';
wwv_flow_imp.g_varchar2_table(161) := '7B783A302C793A307D2C737570706F7274506F696E7465723A2131213D3D48742E737570706F7274506F696E746572262622506F696E7465724576656E7422696E2077696E646F7726262821757C7C64292C656D707479496E736572745468726573686F';
wwv_flow_imp.g_varchar2_table(162) := '6C643A357D3B666F72286E20696E20472E696E697469616C697A65506C7567696E7328746869732C742C69292C69296E20696E20657C7C28655B6E5D3D695B6E5D293B666F72286F20696E2058742865292C7468697329225F223D3D3D6F2E6368617241';
wwv_flow_imp.g_varchar2_table(163) := '7428302926262266756E6374696F6E223D3D747970656F6620746869735B6F5D262628746869735B6F5D3D746869735B6F5D2E62696E64287468697329293B746869732E6E6174697665447261676761626C653D21652E666F72636546616C6C6261636B';
wwv_flow_imp.g_varchar2_table(164) := '262650742C746869732E6E6174697665447261676761626C65262628746869732E6F7074696F6E732E746F75636853746172745468726573686F6C643D31292C652E737570706F7274506F696E7465723F6628742C22706F696E746572646F776E222C74';
wwv_flow_imp.g_varchar2_table(165) := '6869732E5F6F6E5461705374617274293A286628742C226D6F757365646F776E222C746869732E5F6F6E5461705374617274292C6628742C22746F7563687374617274222C746869732E5F6F6E546170537461727429292C746869732E6E617469766544';
wwv_flow_imp.g_varchar2_table(166) := '7261676761626C652626286628742C22647261676F766572222C74686973292C6628742C2264726167656E746572222C7468697329292C5F742E7075736828746869732E656C292C652E73746F72652626652E73746F72652E6765742626746869732E73';
wwv_flow_imp.g_varchar2_table(167) := '6F727428652E73746F72652E6765742874686973297C7C5B5D292C6128746869732C4E2829297D66756E6374696F6E204C7428742C652C6E2C6F2C692C722C612C6C297B76617220732C632C753D745B4B5D2C643D752E6F7074696F6E732E6F6E4D6F76';
wwv_flow_imp.g_varchar2_table(168) := '653B72657475726E2177696E646F772E437573746F6D4576656E747C7C797C7C773F28733D646F63756D656E742E6372656174654576656E7428224576656E742229292E696E69744576656E7428226D6F7665222C21302C2130293A733D6E6577204375';
wwv_flow_imp.g_varchar2_table(169) := '73746F6D4576656E7428226D6F7665222C7B627562626C65733A21302C63616E63656C61626C653A21307D292C732E746F3D652C732E66726F6D3D742C732E647261676765643D6E2C732E64726167676564526563743D6F2C732E72656C617465643D69';
wwv_flow_imp.g_varchar2_table(170) := '7C7C652C732E72656C61746564526563743D727C7C582865292C732E77696C6C496E7365727441667465723D6C2C732E6F726967696E616C4576656E743D612C742E64697370617463684576656E742873292C633D643F642E63616C6C28752C732C6129';
wwv_flow_imp.g_varchar2_table(171) := '3A637D66756E6374696F6E204B742874297B742E647261676761626C653D21317D66756E6374696F6E20577428297B4F743D21317D66756E6374696F6E207A742874297B72657475726E2073657454696D656F757428742C30297D66756E6374696F6E20';
wwv_flow_imp.g_varchar2_table(172) := '47742874297B72657475726E20636C65617254696D656F75742874297D48742E70726F746F747970653D7B636F6E7374727563746F723A48742C5F69734F75747369646554686973456C3A66756E6374696F6E2874297B746869732E656C2E636F6E7461';
wwv_flow_imp.g_varchar2_table(173) := '696E732874297C7C743D3D3D746869732E656C7C7C2862743D6E756C6C297D2C5F676574446972656374696F6E3A66756E6374696F6E28742C65297B72657475726E2266756E6374696F6E223D3D747970656F6620746869732E6F7074696F6E732E6469';
wwv_flow_imp.g_varchar2_table(174) := '72656374696F6E3F746869732E6F7074696F6E732E646972656374696F6E2E63616C6C28746869732C742C652C24293A746869732E6F7074696F6E732E646972656374696F6E7D2C5F6F6E54617053746172743A66756E6374696F6E2865297B69662865';
wwv_flow_imp.g_varchar2_table(175) := '2E63616E63656C61626C65297B766172206E3D746869732C6F3D746869732E656C2C743D746869732E6F7074696F6E732C693D742E70726576656E744F6E46696C7465722C723D652E747970652C613D652E746F75636865732626652E746F7563686573';
wwv_flow_imp.g_varchar2_table(176) := '5B305D7C7C652E706F696E74657254797065262622746F756368223D3D3D652E706F696E746572547970652626652C6C3D28617C7C65292E7461726765742C733D652E7461726765742E736861646F77526F6F74262628652E706174682626652E706174';
wwv_flow_imp.g_varchar2_table(177) := '685B305D7C7C652E636F6D706F736564506174682626652E636F6D706F7365645061746828295B305D297C7C6C2C633D742E66696C7465723B6966282166756E6374696F6E2874297B4D742E6C656E6774683D303B76617220653D742E676574456C656D';
wwv_flow_imp.g_varchar2_table(178) := '656E747342795461674E616D652822696E70757422292C6E3D652E6C656E6774683B666F72283B6E2D2D3B297B766172206F3D655B6E5D3B6F2E636865636B656426264D742E70757368286F297D7D286F292C2124262621282F6D6F757365646F776E7C';
wwv_flow_imp.g_varchar2_table(179) := '706F696E746572646F776E2F2E74657374287229262630213D3D652E627574746F6E7C7C742E64697361626C656429262621732E6973436F6E74656E744564697461626C65262628746869732E6E6174697665447261676761626C657C7C21757C7C216C';
wwv_flow_imp.g_varchar2_table(180) := '7C7C2253454C45435422213D3D6C2E7461674E616D652E746F55707065724361736528292926262128286C3D50286C2C742E647261676761626C652C6F2C2131292926266C2E616E696D617465647C7C6E743D3D3D6C29297B69662872743D6A286C292C';
wwv_flow_imp.g_varchar2_table(181) := '6C743D6A286C2C742E647261676761626C65292C2266756E6374696F6E223D3D747970656F662063297B696628632E63616C6C28746869732C652C6C2C74686973292972657475726E205A287B736F727461626C653A6E2C726F6F74456C3A732C6E616D';
wwv_flow_imp.g_varchar2_table(182) := '653A2266696C746572222C746172676574456C3A6C2C746F456C3A6F2C66726F6D456C3A6F7D292C71282266696C746572222C6E2C7B6576743A657D292C766F696428692626652E70726576656E7444656661756C742829297D656C736520696628633D';
wwv_flow_imp.g_varchar2_table(183) := '632626632E73706C697428222C22292E736F6D652866756E6374696F6E2874297B696628743D5028732C742E7472696D28292C6F2C2131292972657475726E205A287B736F727461626C653A6E2C726F6F74456C3A742C6E616D653A2266696C74657222';
wwv_flow_imp.g_varchar2_table(184) := '2C746172676574456C3A6C2C66726F6D456C3A6F2C746F456C3A6F7D292C71282266696C746572222C6E2C7B6576743A657D292C21307D292972657475726E20766F696428692626652E70726576656E7444656661756C742829293B742E68616E646C65';
wwv_flow_imp.g_varchar2_table(185) := '2626215028732C742E68616E646C652C6F2C2131297C7C746869732E5F7072657061726544726167537461727428652C612C6C297D7D7D2C5F707265706172654472616753746172743A66756E6374696F6E28742C652C6E297B766172206F2C693D7468';
wwv_flow_imp.g_varchar2_table(186) := '69732C723D692E656C2C613D692E6F7074696F6E732C6C3D722E6F776E6572446F63756D656E743B6E2626212426266E2E706172656E744E6F64653D3D3D722626286F3D58286E292C74743D722C513D28243D6E292E706172656E744E6F64652C65743D';
wwv_flow_imp.g_varchar2_table(187) := '242E6E6578745369626C696E672C6E743D6E2C63743D612E67726F75702C64743D7B7461726765743A48742E647261676765643D242C636C69656E74583A28657C7C74292E636C69656E74582C636C69656E74593A28657C7C74292E636C69656E74597D';
wwv_flow_imp.g_varchar2_table(188) := '2C67743D64742E636C69656E74582D6F2E6C6566742C6D743D64742E636C69656E74592D6F2E746F702C746869732E5F6C617374583D28657C7C74292E636C69656E74582C746869732E5F6C617374593D28657C7C74292E636C69656E74592C242E7374';
wwv_flow_imp.g_varchar2_table(189) := '796C655B2277696C6C2D6368616E6765225D3D22616C6C222C6F3D66756E6374696F6E28297B71282264656C6179456E646564222C692C7B6576743A747D292C48742E6576656E7443616E63656C65643F692E5F6F6E44726F7028293A28692E5F646973';
wwv_flow_imp.g_varchar2_table(190) := '61626C6544656C61796564447261674576656E747328292C21632626692E6E6174697665447261676761626C65262628242E647261676761626C653D2130292C692E5F7472696767657244726167537461727428742C65292C5A287B736F727461626C65';
wwv_flow_imp.g_varchar2_table(191) := '3A692C6E616D653A2263686F6F7365222C6F726967696E616C4576656E743A747D292C6B28242C612E63686F73656E436C6173732C213029297D2C612E69676E6F72652E73706C697428222C22292E666F72456163682866756E6374696F6E2874297B45';
wwv_flow_imp.g_varchar2_table(192) := '28242C742E7472696D28292C4B74297D292C66286C2C22647261676F766572222C4674292C66286C2C226D6F7573656D6F7665222C4674292C66286C2C22746F7563686D6F7665222C4674292C612E737570706F7274506F696E7465723F2866286C2C22';
wwv_flow_imp.g_varchar2_table(193) := '706F696E7465727570222C692E5F6F6E44726F70292C746869732E6E6174697665447261676761626C657C7C66286C2C22706F696E74657263616E63656C222C692E5F6F6E44726F7029293A2866286C2C226D6F7573657570222C692E5F6F6E44726F70';
wwv_flow_imp.g_varchar2_table(194) := '292C66286C2C22746F756368656E64222C692E5F6F6E44726F70292C66286C2C22746F75636863616E63656C222C692E5F6F6E44726F7029292C632626746869732E6E6174697665447261676761626C65262628746869732E6F7074696F6E732E746F75';
wwv_flow_imp.g_varchar2_table(195) := '636853746172745468726573686F6C643D342C242E647261676761626C653D2130292C71282264656C61795374617274222C746869732C7B6576743A747D292C21612E64656C61797C7C612E64656C61794F6E546F7563684F6E6C79262621657C7C7468';
wwv_flow_imp.g_varchar2_table(196) := '69732E6E6174697665447261676761626C65262628777C7C79293F6F28293A48742E6576656E7443616E63656C65643F746869732E5F6F6E44726F7028293A28612E737570706F7274506F696E7465723F2866286C2C22706F696E7465727570222C692E';
wwv_flow_imp.g_varchar2_table(197) := '5F64697361626C6544656C6179656444726167292C66286C2C22706F696E74657263616E63656C222C692E5F64697361626C6544656C617965644472616729293A2866286C2C226D6F7573657570222C692E5F64697361626C6544656C61796564447261';
wwv_flow_imp.g_varchar2_table(198) := '67292C66286C2C22746F756368656E64222C692E5F64697361626C6544656C6179656444726167292C66286C2C22746F75636863616E63656C222C692E5F64697361626C6544656C617965644472616729292C66286C2C226D6F7573656D6F7665222C69';
wwv_flow_imp.g_varchar2_table(199) := '2E5F64656C6179656444726167546F7563684D6F766548616E646C6572292C66286C2C22746F7563686D6F7665222C692E5F64656C6179656444726167546F7563684D6F766548616E646C6572292C612E737570706F7274506F696E746572262666286C';
wwv_flow_imp.g_varchar2_table(200) := '2C22706F696E7465726D6F7665222C692E5F64656C6179656444726167546F7563684D6F766548616E646C6572292C692E5F64726167537461727454696D65723D73657454696D656F7574286F2C612E64656C61792929297D2C5F64656C617965644472';
wwv_flow_imp.g_varchar2_table(201) := '6167546F7563684D6F766548616E646C65723A66756E6374696F6E2874297B743D742E746F75636865733F742E746F75636865735B305D3A743B4D6174682E6D6178284D6174682E61627328742E636C69656E74582D746869732E5F6C61737458292C4D';
wwv_flow_imp.g_varchar2_table(202) := '6174682E61627328742E636C69656E74592D746869732E5F6C6173745929293E3D4D6174682E666C6F6F7228746869732E6F7074696F6E732E746F75636853746172745468726573686F6C642F28746869732E6E6174697665447261676761626C652626';
wwv_flow_imp.g_varchar2_table(203) := '77696E646F772E646576696365506978656C526174696F7C7C3129292626746869732E5F64697361626C6544656C617965644472616728297D2C5F64697361626C6544656C61796564447261673A66756E6374696F6E28297B2426264B742824292C636C';
wwv_flow_imp.g_varchar2_table(204) := '65617254696D656F757428746869732E5F64726167537461727454696D6572292C746869732E5F64697361626C6544656C61796564447261674576656E747328297D2C5F64697361626C6544656C61796564447261674576656E74733A66756E6374696F';
wwv_flow_imp.g_varchar2_table(205) := '6E28297B76617220743D746869732E656C2E6F776E6572446F63756D656E743B7028742C226D6F7573657570222C746869732E5F64697361626C6544656C6179656444726167292C7028742C22746F756368656E64222C746869732E5F64697361626C65';
wwv_flow_imp.g_varchar2_table(206) := '44656C6179656444726167292C7028742C22746F75636863616E63656C222C746869732E5F64697361626C6544656C6179656444726167292C7028742C22706F696E7465727570222C746869732E5F64697361626C6544656C6179656444726167292C70';
wwv_flow_imp.g_varchar2_table(207) := '28742C22706F696E74657263616E63656C222C746869732E5F64697361626C6544656C6179656444726167292C7028742C226D6F7573656D6F7665222C746869732E5F64656C6179656444726167546F7563684D6F766548616E646C6572292C7028742C';
wwv_flow_imp.g_varchar2_table(208) := '22746F7563686D6F7665222C746869732E5F64656C6179656444726167546F7563684D6F766548616E646C6572292C7028742C22706F696E7465726D6F7665222C746869732E5F64656C6179656444726167546F7563684D6F766548616E646C6572297D';
wwv_flow_imp.g_varchar2_table(209) := '2C5F747269676765724472616753746172743A66756E6374696F6E28742C65297B653D657C7C22746F756368223D3D742E706F696E746572547970652626742C21746869732E6E6174697665447261676761626C657C7C653F746869732E6F7074696F6E';
wwv_flow_imp.g_varchar2_table(210) := '732E737570706F7274506F696E7465723F6628646F63756D656E742C22706F696E7465726D6F7665222C746869732E5F6F6E546F7563684D6F7665293A6628646F63756D656E742C653F22746F7563686D6F7665223A226D6F7573656D6F7665222C7468';
wwv_flow_imp.g_varchar2_table(211) := '69732E5F6F6E546F7563684D6F7665293A286628242C2264726167656E64222C74686973292C662874742C22647261677374617274222C746869732E5F6F6E44726167537461727429293B7472797B646F63756D656E742E73656C656374696F6E3F7A74';
wwv_flow_imp.g_varchar2_table(212) := '2866756E6374696F6E28297B646F63756D656E742E73656C656374696F6E2E656D70747928297D293A77696E646F772E67657453656C656374696F6E28292E72656D6F7665416C6C52616E67657328297D63617463682874297B7D7D2C5F647261675374';
wwv_flow_imp.g_varchar2_table(213) := '61727465643A66756E6374696F6E28742C65297B766172206E3B45743D21312C74742626243F287128226472616753746172746564222C746869732C7B6576743A657D292C746869732E6E6174697665447261676761626C6526266628646F63756D656E';
wwv_flow_imp.g_varchar2_table(214) := '742C22647261676F766572222C6A74292C6E3D746869732E6F7074696F6E732C747C7C6B28242C6E2E64726167436C6173732C2131292C6B28242C6E2E67686F7374436C6173732C2130292C48742E6163746976653D746869732C742626746869732E5F';
wwv_flow_imp.g_varchar2_table(215) := '617070656E6447686F737428292C5A287B736F727461626C653A746869732C6E616D653A227374617274222C6F726967696E616C4576656E743A657D29293A746869732E5F6E756C6C696E6728297D2C5F656D756C617465447261674F7665723A66756E';
wwv_flow_imp.g_varchar2_table(216) := '6374696F6E28297B6966286874297B746869732E5F6C617374583D68742E636C69656E74582C746869732E5F6C617374593D68742E636C69656E74592C597428293B666F722876617220743D646F63756D656E742E656C656D656E7446726F6D506F696E';
wwv_flow_imp.g_varchar2_table(217) := '742868742E636C69656E74582C68742E636C69656E7459292C653D743B742626742E736861646F77526F6F74262628743D742E736861646F77526F6F742E656C656D656E7446726F6D506F696E742868742E636C69656E74582C68742E636C69656E7459';
wwv_flow_imp.g_varchar2_table(218) := '2929213D3D653B29653D743B696628242E706172656E744E6F64655B4B5D2E5F69734F75747369646554686973456C2874292C6529646F7B696628655B4B5D29696628655B4B5D2E5F6F6E447261674F766572287B636C69656E74583A68742E636C6965';
wwv_flow_imp.g_varchar2_table(219) := '6E74582C636C69656E74593A68742E636C69656E74592C7461726765743A742C726F6F74456C3A657D29262621746869732E6F7074696F6E732E647261676F766572427562626C6529627265616B7D7768696C6528653D6D28743D6529293B427428297D';
wwv_flow_imp.g_varchar2_table(220) := '7D2C5F6F6E546F7563684D6F76653A66756E6374696F6E2874297B6966286474297B76617220653D746869732E6F7074696F6E732C6E3D652E66616C6C6261636B546F6C6572616E63652C6F3D652E66616C6C6261636B4F66667365742C693D742E746F';
wwv_flow_imp.g_varchar2_table(221) := '75636865733F742E746F75636865735B305D3A742C723D4A262644284A2C2130292C613D4A2626722626722E612C6C3D4A2626722626722E642C653D4E7426264474262653284474292C613D28692E636C69656E74582D64742E636C69656E74582B6F2E';
wwv_flow_imp.g_varchar2_table(222) := '78292F28617C7C31292B28653F655B305D2D78745B305D3A30292F28617C7C31292C6C3D28692E636C69656E74592D64742E636C69656E74592B6F2E79292F286C7C7C31292B28653F655B315D2D78745B315D3A30292F286C7C7C31293B696628214874';
wwv_flow_imp.g_varchar2_table(223) := '2E6163746976652626214574297B6966286E26264D6174682E6D6178284D6174682E61627328692E636C69656E74582D746869732E5F6C61737458292C4D6174682E61627328692E636C69656E74592D746869732E5F6C6173745929293C6E2972657475';
wwv_flow_imp.g_varchar2_table(224) := '726E3B746869732E5F6F6E44726167537461727428742C2130297D4A262628723F28722E652B3D612D2866747C7C30292C722E662B3D6C2D2870747C7C3029293A723D7B613A312C623A302C633A302C643A312C653A612C663A6C7D2C723D226D617472';
wwv_flow_imp.g_varchar2_table(225) := '697828222E636F6E63617428722E612C222C22292E636F6E63617428722E622C222C22292E636F6E63617428722E632C222C22292E636F6E63617428722E642C222C22292E636F6E63617428722E652C222C22292E636F6E63617428722E662C22292229';
wwv_flow_imp.g_varchar2_table(226) := '2C52284A2C227765626B69745472616E73666F726D222C72292C52284A2C226D6F7A5472616E73666F726D222C72292C52284A2C226D735472616E73666F726D222C72292C52284A2C227472616E73666F726D222C72292C66743D612C70743D6C2C6874';
wwv_flow_imp.g_varchar2_table(227) := '3D69292C742E63616E63656C61626C652626742E70726576656E7444656661756C7428297D7D2C5F617070656E6447686F73743A66756E6374696F6E28297B696628214A297B76617220743D746869732E6F7074696F6E732E66616C6C6261636B4F6E42';
wwv_flow_imp.g_varchar2_table(228) := '6F64793F646F63756D656E742E626F64793A74742C653D5828242C21302C4E742C21302C74292C6E3D746869732E6F7074696F6E733B6966284E74297B666F722844743D743B22737461746963223D3D3D522844742C22706F736974696F6E2229262622';
wwv_flow_imp.g_varchar2_table(229) := '6E6F6E65223D3D3D522844742C227472616E73666F726D222926264474213D3D646F63756D656E743B2944743D44742E706172656E744E6F64653B4474213D3D646F63756D656E742E626F647926264474213D3D646F63756D656E742E646F63756D656E';
wwv_flow_imp.g_varchar2_table(230) := '74456C656D656E743F2844743D3D3D646F63756D656E7426262844743D4F2829292C652E746F702B3D44742E7363726F6C6C546F702C652E6C6566742B3D44742E7363726F6C6C4C656674293A44743D4F28292C78743D53284474297D6B284A3D242E63';
wwv_flow_imp.g_varchar2_table(231) := '6C6F6E654E6F6465282130292C6E2E67686F7374436C6173732C2131292C6B284A2C6E2E66616C6C6261636B436C6173732C2130292C6B284A2C6E2E64726167436C6173732C2130292C52284A2C227472616E736974696F6E222C2222292C52284A2C22';
wwv_flow_imp.g_varchar2_table(232) := '7472616E73666F726D222C2222292C52284A2C22626F782D73697A696E67222C22626F726465722D626F7822292C52284A2C226D617267696E222C30292C52284A2C22746F70222C652E746F70292C52284A2C226C656674222C652E6C656674292C5228';
wwv_flow_imp.g_varchar2_table(233) := '4A2C227769647468222C652E7769647468292C52284A2C22686569676874222C652E686569676874292C52284A2C226F706163697479222C22302E3822292C52284A2C22706F736974696F6E222C4E743F226162736F6C757465223A2266697865642229';
wwv_flow_imp.g_varchar2_table(234) := '2C52284A2C227A496E646578222C2231303030303022292C52284A2C22706F696E7465724576656E7473222C226E6F6E6522292C48742E67686F73743D4A2C742E617070656E644368696C64284A292C52284A2C227472616E73666F726D2D6F72696769';
wwv_flow_imp.g_varchar2_table(235) := '6E222C67742F7061727365496E74284A2E7374796C652E7769647468292A3130302B222520222B6D742F7061727365496E74284A2E7374796C652E686569676874292A3130302B222522297D7D2C5F6F6E4472616753746172743A66756E6374696F6E28';
wwv_flow_imp.g_varchar2_table(236) := '742C65297B766172206E3D746869732C6F3D742E646174615472616E736665722C693D6E2E6F7074696F6E733B712822647261675374617274222C746869732C7B6576743A747D292C48742E6576656E7443616E63656C65643F746869732E5F6F6E4472';
wwv_flow_imp.g_varchar2_table(237) := '6F7028293A287128227365747570436C6F6E65222C74686973292C48742E6576656E7443616E63656C65647C7C28286F743D54282429292E72656D6F76654174747269627574652822696422292C6F742E647261676761626C653D21312C6F742E737479';
wwv_flow_imp.g_varchar2_table(238) := '6C655B2277696C6C2D6368616E6765225D3D22222C746869732E5F68696465436C6F6E6528292C6B286F742C746869732E6F7074696F6E732E63686F73656E436C6173732C2131292C48742E636C6F6E653D6F74292C6E2E636C6F6E6549643D7A742866';
wwv_flow_imp.g_varchar2_table(239) := '756E6374696F6E28297B712822636C6F6E65222C6E292C48742E6576656E7443616E63656C65647C7C286E2E6F7074696F6E732E72656D6F7665436C6F6E654F6E486964657C7C74742E696E736572744265666F7265286F742C24292C6E2E5F68696465';
wwv_flow_imp.g_varchar2_table(240) := '436C6F6E6528292C5A287B736F727461626C653A6E2C6E616D653A22636C6F6E65227D29297D292C657C7C6B28242C692E64726167436C6173732C2130292C653F2853743D21302C6E2E5F6C6F6F7049643D736574496E74657276616C286E2E5F656D75';
wwv_flow_imp.g_varchar2_table(241) := '6C617465447261674F7665722C353029293A287028646F63756D656E742C226D6F7573657570222C6E2E5F6F6E44726F70292C7028646F63756D656E742C22746F756368656E64222C6E2E5F6F6E44726F70292C7028646F63756D656E742C22746F7563';
wwv_flow_imp.g_varchar2_table(242) := '6863616E63656C222C6E2E5F6F6E44726F70292C6F2626286F2E656666656374416C6C6F7765643D226D6F7665222C692E736574446174612626692E736574446174612E63616C6C286E2C6F2C2429292C6628646F63756D656E742C2264726F70222C6E';
wwv_flow_imp.g_varchar2_table(243) := '292C5228242C227472616E73666F726D222C227472616E736C6174655A2830292229292C45743D21302C6E2E5F64726167537461727449643D7A74286E2E5F64726167537461727465642E62696E64286E2C652C7429292C6628646F63756D656E742C22';
wwv_flow_imp.g_varchar2_table(244) := '73656C6563747374617274222C6E292C76743D21302C77696E646F772E67657453656C656374696F6E28292E72656D6F7665416C6C52616E67657328292C7526265228646F63756D656E742E626F64792C22757365722D73656C656374222C226E6F6E65';
wwv_flow_imp.g_varchar2_table(245) := '2229297D2C5F6F6E447261674F7665723A66756E6374696F6E286E297B766172206F2C692C722C742C652C613D746869732E656C2C6C3D6E2E7461726765742C733D746869732E6F7074696F6E732C633D732E67726F75702C753D48742E616374697665';
wwv_flow_imp.g_varchar2_table(246) := '2C643D63743D3D3D632C683D732E736F72742C663D75747C7C752C703D746869732C673D21313B696628214F74297B696628766F69642030213D3D6E2E70726576656E7444656661756C7426266E2E63616E63656C61626C6526266E2E70726576656E74';
wwv_flow_imp.g_varchar2_table(247) := '44656661756C7428292C6C3D50286C2C732E647261676761626C652C612C2130292C4F2822647261674F76657222292C48742E6576656E7443616E63656C65642972657475726E20673B696628242E636F6E7461696E73286E2E746172676574297C7C6C';
wwv_flow_imp.g_varchar2_table(248) := '2E616E696D6174656426266C2E616E696D6174696E675826266C2E616E696D6174696E67597C7C702E5F69676E6F72655768696C65416E696D6174696E673D3D3D6C2972657475726E2041282131293B69662853743D21312C75262621732E6469736162';
wwv_flow_imp.g_varchar2_table(249) := '6C6564262628643F687C7C28693D51213D3D7474293A75743D3D3D746869737C7C28746869732E6C6173745075744D6F64653D63742E636865636B50756C6C28746869732C752C242C6E29292626632E636865636B50757428746869732C752C242C6E29';
wwv_flow_imp.g_varchar2_table(250) := '29297B696628723D22766572746963616C223D3D3D746869732E5F676574446972656374696F6E286E2C6C292C6F3D582824292C4F2822647261674F76657256616C696422292C48742E6576656E7443616E63656C65642972657475726E20673B696628';
wwv_flow_imp.g_varchar2_table(251) := '692972657475726E20513D74742C4D28292C746869732E5F68696465436C6F6E6528292C4F282272657665727422292C48742E6576656E7443616E63656C65647C7C2865743F74742E696E736572744265666F726528242C6574293A74742E617070656E';
wwv_flow_imp.g_varchar2_table(252) := '644368696C64282429292C41282130293B766172206D3D4628612C732E647261676761626C65293B6966286D262628533D6E2C633D722C783D5828462828453D74686973292E656C2C452E6F7074696F6E732E647261676761626C6529292C453D4C2845';
wwv_flow_imp.g_varchar2_table(253) := '2E656C2C452E6F7074696F6E732C4A292C2128633F532E636C69656E74583E452E72696768742B31307C7C532E636C69656E74593E782E626F74746F6D2626532E636C69656E74583E782E6C6566743A532E636C69656E74593E452E626F74746F6D2B31';
wwv_flow_imp.g_varchar2_table(254) := '307C7C532E636C69656E74583E782E72696768742626532E636C69656E74593E782E746F70297C7C6D2E616E696D6174656429297B6966286D262628743D6E2C653D722C433D58284228285F3D74686973292E656C2C302C5F2E6F7074696F6E732C2130';
wwv_flow_imp.g_varchar2_table(255) := '29292C5F3D4C285F2E656C2C5F2E6F7074696F6E732C4A292C653F742E636C69656E74583C5F2E6C6566742D31307C7C742E636C69656E74593C432E746F702626742E636C69656E74583C432E72696768743A742E636C69656E74593C5F2E746F702D31';
wwv_flow_imp.g_varchar2_table(256) := '307C7C742E636C69656E74593C432E626F74746F6D2626742E636C69656E74583C432E6C65667429297B76617220763D4228612C302C732C2130293B696628763D3D3D242972657475726E2041282131293B696628443D58286C3D76292C2131213D3D4C';
wwv_flow_imp.g_varchar2_table(257) := '742874742C612C242C6F2C6C2C442C6E2C2131292972657475726E204D28292C612E696E736572744265666F726528242C76292C513D612C4E28292C41282130297D656C7365206966286C2E706172656E744E6F64653D3D3D61297B76617220622C792C';
wwv_flow_imp.g_varchar2_table(258) := '772C443D58286C292C453D242E706172656E744E6F6465213D3D612C533D28533D242E616E696D617465642626242E746F526563747C7C6F2C783D6C2E616E696D6174656426266C2E746F526563747C7C442C5F3D28653D72293F532E6C6566743A532E';
wwv_flow_imp.g_varchar2_table(259) := '746F702C743D653F532E72696768743A532E626F74746F6D2C433D653F532E77696474683A532E6865696768742C763D653F782E6C6566743A782E746F702C533D653F782E72696768743A782E626F74746F6D2C783D653F782E77696474683A782E6865';
wwv_flow_imp.g_varchar2_table(260) := '696768742C21285F3D3D3D767C7C743D3D3D537C7C5F2B432F323D3D3D762B782F3229292C5F3D723F22746F70223A226C656674222C433D59286C2C22746F70222C22746F7022297C7C5928242C22746F70222C22746F7022292C763D433F432E736372';
wwv_flow_imp.g_varchar2_table(261) := '6F6C6C546F703A766F696420303B6966286274213D3D6C262628793D445B5F5D2C43743D21312C54743D21532626732E696E76657274537761707C7C45292C30213D3D28623D66756E6374696F6E28742C652C6E2C6F2C692C722C612C6C297B76617220';
wwv_flow_imp.g_varchar2_table(262) := '733D6F3F742E636C69656E74593A742E636C69656E74582C633D6F3F6E2E6865696768743A6E2E77696474682C743D6F3F6E2E746F703A6E2E6C6566742C6F3D6F3F6E2E626F74746F6D3A6E2E72696768742C6E3D21313B6966282161296966286C2626';
wwv_flow_imp.g_varchar2_table(263) := '77743C632A69297B69662843743D214374262628313D3D3D79743F742B632A722F323C733A733C6F2D632A722F32293F21303A4374296E3D21303B656C736520696628313D3D3D79743F733C742B77743A6F2D77743C732972657475726E2D79747D656C';
wwv_flow_imp.g_varchar2_table(264) := '736520696628742B632A28312D69292F323C732626733C6F2D632A28312D69292F322972657475726E2066756E6374696F6E2874297B72657475726E206A2824293C6A2874293F313A2D317D2865293B696628286E3D6E7C7C6129262628733C742B632A';
wwv_flow_imp.g_varchar2_table(265) := '722F327C7C6F2D632A722F323C73292972657475726E20742B632F323C733F313A2D313B72657475726E20307D286E2C6C2C442C722C533F313A732E737761705468726573686F6C642C6E756C6C3D3D732E696E76657274656453776170546872657368';
wwv_flow_imp.g_varchar2_table(266) := '6F6C643F732E737761705468726573686F6C643A732E696E766572746564537761705468726573686F6C642C54742C62743D3D3D6C292929666F722876617220543D6A2824293B28773D512E6368696C6472656E5B542D3D625D29262628226E6F6E6522';
wwv_flow_imp.g_varchar2_table(267) := '3D3D3D5228772C22646973706C617922297C7C773D3D3D4A293B293B696628303D3D3D627C7C773D3D3D6C2972657475726E2041282131293B79743D623B76617220783D2862743D6C292E6E657874456C656D656E745369626C696E672C453D21312C53';
wwv_flow_imp.g_varchar2_table(268) := '3D4C742874742C612C242C6F2C6C2C442C6E2C453D313D3D3D62293B6966282131213D3D532972657475726E2031213D3D5326262D31213D3D537C7C28453D313D3D3D53292C4F743D21302C73657454696D656F75742857742C3330292C4D28292C4526';
wwv_flow_imp.g_varchar2_table(269) := '2621783F612E617070656E644368696C642824293A6C2E706172656E744E6F64652E696E736572744265666F726528242C453F783A6C292C4326264828432C302C762D432E7363726F6C6C546F70292C513D242E706172656E744E6F64652C766F696420';
wwv_flow_imp.g_varchar2_table(270) := '303D3D3D797C7C54747C7C2877743D4D6174682E61627328792D58286C295B5F5D29292C4E28292C41282130297D7D656C73657B6966286D3D3D3D242972657475726E2041282131293B696628286C3D6D2626613D3D3D6E2E7461726765743F6D3A6C29';
wwv_flow_imp.g_varchar2_table(271) := '262628443D58286C29292C2131213D3D4C742874742C612C242C6F2C6C2C442C6E2C21216C292972657475726E204D28292C6D26266D2E6E6578745369626C696E673F612E696E736572744265666F726528242C6D2E6E6578745369626C696E67293A61';
wwv_flow_imp.g_varchar2_table(272) := '2E617070656E644368696C642824292C513D612C4E28292C41282130297D696628612E636F6E7461696E732824292972657475726E2041282131297D72657475726E21317D66756E6374696F6E204F28742C65297B7128742C702C49287B6576743A6E2C';
wwv_flow_imp.g_varchar2_table(273) := '69734F776E65723A642C617869733A723F22766572746963616C223A22686F72697A6F6E74616C222C7265766572743A692C64726167526563743A6F2C746172676574526563743A442C63616E536F72743A682C66726F6D536F727461626C653A662C74';
wwv_flow_imp.g_varchar2_table(274) := '61726765743A6C2C636F6D706C657465643A412C6F6E4D6F76653A66756E6374696F6E28742C65297B72657475726E204C742874742C612C242C6F2C742C582874292C6E2C65297D2C6368616E6765643A4E7D2C6529297D66756E6374696F6E204D2829';
wwv_flow_imp.g_varchar2_table(275) := '7B4F2822647261674F766572416E696D6174696F6E4361707475726522292C702E63617074757265416E696D6174696F6E537461746528292C70213D3D662626662E63617074757265416E696D6174696F6E537461746528297D66756E6374696F6E2041';
wwv_flow_imp.g_varchar2_table(276) := '2874297B72657475726E204F2822647261674F766572436F6D706C65746564222C7B696E73657274696F6E3A747D292C74262628643F752E5F68696465436C6F6E6528293A752E5F73686F77436C6F6E652870292C70213D3D662626286B28242C287574';
wwv_flow_imp.g_varchar2_table(277) := '7C7C75292E6F7074696F6E732E67686F7374436C6173732C2131292C6B28242C732E67686F7374436C6173732C213029292C7574213D3D70262670213D3D48742E6163746976653F75743D703A703D3D3D48742E6163746976652626757426262875743D';
wwv_flow_imp.g_varchar2_table(278) := '6E756C6C292C663D3D3D70262628702E5F69676E6F72655768696C65416E696D6174696E673D6C292C702E616E696D617465416C6C2866756E6374696F6E28297B4F2822647261674F766572416E696D6174696F6E436F6D706C65746522292C702E5F69';
wwv_flow_imp.g_varchar2_table(279) := '676E6F72655768696C65416E696D6174696E673D6E756C6C7D292C70213D3D66262628662E616E696D617465416C6C28292C662E5F69676E6F72655768696C65416E696D6174696E673D6E756C6C29292C286C3D3D3D24262621242E616E696D61746564';
wwv_flow_imp.g_varchar2_table(280) := '7C7C6C3D3D3D612626216C2E616E696D617465642926262862743D6E756C6C292C732E647261676F766572427562626C657C7C6E2E726F6F74456C7C7C6C3D3D3D646F63756D656E747C7C28242E706172656E744E6F64655B4B5D2E5F69734F75747369';
wwv_flow_imp.g_varchar2_table(281) := '646554686973456C286E2E746172676574292C747C7C4674286E29292C21732E647261676F766572427562626C6526266E2E73746F7050726F7061676174696F6E26266E2E73746F7050726F7061676174696F6E28292C673D21307D66756E6374696F6E';
wwv_flow_imp.g_varchar2_table(282) := '204E28297B61743D6A2824292C73743D6A28242C732E647261676761626C65292C5A287B736F727461626C653A702C6E616D653A226368616E6765222C746F456C3A612C6E6577496E6465783A61742C6E6577447261676761626C65496E6465783A7374';
wwv_flow_imp.g_varchar2_table(283) := '2C6F726967696E616C4576656E743A6E7D297D7D2C5F69676E6F72655768696C65416E696D6174696E673A6E756C6C2C5F6F66664D6F76654576656E74733A66756E6374696F6E28297B7028646F63756D656E742C226D6F7573656D6F7665222C746869';
wwv_flow_imp.g_varchar2_table(284) := '732E5F6F6E546F7563684D6F7665292C7028646F63756D656E742C22746F7563686D6F7665222C746869732E5F6F6E546F7563684D6F7665292C7028646F63756D656E742C22706F696E7465726D6F7665222C746869732E5F6F6E546F7563684D6F7665';
wwv_flow_imp.g_varchar2_table(285) := '292C7028646F63756D656E742C22647261676F766572222C4674292C7028646F63756D656E742C226D6F7573656D6F7665222C4674292C7028646F63756D656E742C22746F7563686D6F7665222C4674297D2C5F6F666655704576656E74733A66756E63';
wwv_flow_imp.g_varchar2_table(286) := '74696F6E28297B76617220743D746869732E656C2E6F776E6572446F63756D656E743B7028742C226D6F7573657570222C746869732E5F6F6E44726F70292C7028742C22746F756368656E64222C746869732E5F6F6E44726F70292C7028742C22706F69';
wwv_flow_imp.g_varchar2_table(287) := '6E7465727570222C746869732E5F6F6E44726F70292C7028742C22706F696E74657263616E63656C222C746869732E5F6F6E44726F70292C7028742C22746F75636863616E63656C222C746869732E5F6F6E44726F70292C7028646F63756D656E742C22';
wwv_flow_imp.g_varchar2_table(288) := '73656C6563747374617274222C74686973297D2C5F6F6E44726F703A66756E6374696F6E2874297B76617220653D746869732E656C2C6E3D746869732E6F7074696F6E733B61743D6A2824292C73743D6A28242C6E2E647261676761626C65292C712822';
wwv_flow_imp.g_varchar2_table(289) := '64726F70222C746869732C7B6576743A747D292C513D242626242E706172656E744E6F64652C61743D6A2824292C73743D6A28242C6E2E647261676761626C65292C48742E6576656E7443616E63656C65647C7C2843743D54743D45743D21312C636C65';
wwv_flow_imp.g_varchar2_table(290) := '6172496E74657276616C28746869732E5F6C6F6F704964292C636C65617254696D656F757428746869732E5F64726167537461727454696D6572292C477428746869732E636C6F6E654964292C477428746869732E5F6472616753746172744964292C74';
wwv_flow_imp.g_varchar2_table(291) := '6869732E6E6174697665447261676761626C652626287028646F63756D656E742C2264726F70222C74686973292C7028652C22647261677374617274222C746869732E5F6F6E44726167537461727429292C746869732E5F6F66664D6F76654576656E74';
wwv_flow_imp.g_varchar2_table(292) := '7328292C746869732E5F6F666655704576656E747328292C7526265228646F63756D656E742E626F64792C22757365722D73656C656374222C2222292C5228242C227472616E73666F726D222C2222292C742626287674262628742E63616E63656C6162';
wwv_flow_imp.g_varchar2_table(293) := '6C652626742E70726576656E7444656661756C7428292C6E2E64726F70427562626C657C7C742E73746F7050726F7061676174696F6E2829292C4A26264A2E706172656E744E6F646526264A2E706172656E744E6F64652E72656D6F76654368696C6428';
wwv_flow_imp.g_varchar2_table(294) := '4A292C2874743D3D3D517C7C7574262622636C6F6E6522213D3D75742E6C6173745075744D6F64652926266F7426266F742E706172656E744E6F646526266F742E706172656E744E6F64652E72656D6F76654368696C64286F74292C2426262874686973';
wwv_flow_imp.g_varchar2_table(295) := '2E6E6174697665447261676761626C6526267028242C2264726167656E64222C74686973292C4B742824292C242E7374796C655B2277696C6C2D6368616E6765225D3D22222C7674262621457426266B28242C2875747C7C74686973292E6F7074696F6E';
wwv_flow_imp.g_varchar2_table(296) := '732E67686F7374436C6173732C2131292C6B28242C746869732E6F7074696F6E732E63686F73656E436C6173732C2131292C5A287B736F727461626C653A746869732C6E616D653A22756E63686F6F7365222C746F456C3A512C6E6577496E6465783A6E';
wwv_flow_imp.g_varchar2_table(297) := '756C6C2C6E6577447261676761626C65496E6465783A6E756C6C2C6F726967696E616C4576656E743A747D292C7474213D3D513F28303C3D61742626285A287B726F6F74456C3A512C6E616D653A22616464222C746F456C3A512C66726F6D456C3A7474';
wwv_flow_imp.g_varchar2_table(298) := '2C6F726967696E616C4576656E743A747D292C5A287B736F727461626C653A746869732C6E616D653A2272656D6F7665222C746F456C3A512C6F726967696E616C4576656E743A747D292C5A287B726F6F74456C3A512C6E616D653A22736F7274222C74';
wwv_flow_imp.g_varchar2_table(299) := '6F456C3A512C66726F6D456C3A74742C6F726967696E616C4576656E743A747D292C5A287B736F727461626C653A746869732C6E616D653A22736F7274222C746F456C3A512C6F726967696E616C4576656E743A747D29292C7574262675742E73617665';
wwv_flow_imp.g_varchar2_table(300) := '2829293A6174213D3D72742626303C3D61742626285A287B736F727461626C653A746869732C6E616D653A22757064617465222C746F456C3A512C6F726967696E616C4576656E743A747D292C5A287B736F727461626C653A746869732C6E616D653A22';
wwv_flow_imp.g_varchar2_table(301) := '736F7274222C746F456C3A512C6F726967696E616C4576656E743A747D29292C48742E6163746976652626286E756C6C213D617426262D31213D3D61747C7C2861743D72742C73743D6C74292C5A287B736F727461626C653A746869732C6E616D653A22';
wwv_flow_imp.g_varchar2_table(302) := '656E64222C746F456C3A512C6F726967696E616C4576656E743A747D292C746869732E736176652829292929292C746869732E5F6E756C6C696E6728297D2C5F6E756C6C696E673A66756E6374696F6E28297B7128226E756C6C696E67222C7468697329';
wwv_flow_imp.g_varchar2_table(303) := '2C74743D243D513D4A3D65743D6F743D6E743D69743D64743D68743D76743D61743D73743D72743D6C743D62743D79743D75743D63743D48742E647261676765643D48742E67686F73743D48742E636C6F6E653D48742E6163746976653D6E756C6C3B76';
wwv_flow_imp.g_varchar2_table(304) := '617220653D746869732E656C3B4D742E666F72456163682866756E6374696F6E2874297B652E636F6E7461696E73287429262628742E636865636B65643D2130297D292C4D742E6C656E6774683D66743D70743D307D2C68616E646C654576656E743A66';
wwv_flow_imp.g_varchar2_table(305) := '756E6374696F6E2874297B73776974636828742E74797065297B636173652264726F70223A636173652264726167656E64223A746869732E5F6F6E44726F702874293B627265616B3B636173652264726167656E746572223A6361736522647261676F76';
wwv_flow_imp.g_varchar2_table(306) := '6572223A24262628746869732E5F6F6E447261674F7665722874292C66756E6374696F6E2874297B742E646174615472616E73666572262628742E646174615472616E736665722E64726F704566666563743D226D6F766522293B742E63616E63656C61';
wwv_flow_imp.g_varchar2_table(307) := '626C652626742E70726576656E7444656661756C7428297D287429293B627265616B3B636173652273656C6563747374617274223A742E70726576656E7444656661756C7428297D7D2C746F41727261793A66756E6374696F6E28297B666F7228766172';
wwv_flow_imp.g_varchar2_table(308) := '20742C653D5B5D2C6E3D746869732E656C2E6368696C6472656E2C6F3D302C693D6E2E6C656E6774682C723D746869732E6F7074696F6E733B6F3C693B6F2B2B295028743D6E5B6F5D2C722E647261676761626C652C746869732E656C2C213129262665';
wwv_flow_imp.g_varchar2_table(309) := '2E7075736828742E67657441747472696275746528722E64617461496441747472297C7C66756E6374696F6E2874297B76617220653D742E7461674E616D652B742E636C6173734E616D652B742E7372632B742E687265662B742E74657874436F6E7465';
wwv_flow_imp.g_varchar2_table(310) := '6E742C6E3D652E6C656E6774682C6F3D303B666F72283B6E2D2D3B296F2B3D652E63686172436F64654174286E293B72657475726E206F2E746F537472696E67283336297D287429293B72657475726E20657D2C736F72743A66756E6374696F6E28742C';
wwv_flow_imp.g_varchar2_table(311) := '65297B766172206E3D7B7D2C6F3D746869732E656C3B746869732E746F417272617928292E666F72456163682866756E6374696F6E28742C65297B653D6F2E6368696C6472656E5B655D3B5028652C746869732E6F7074696F6E732E647261676761626C';
wwv_flow_imp.g_varchar2_table(312) := '652C6F2C2131292626286E5B745D3D65297D2C74686973292C652626746869732E63617074757265416E696D6174696F6E537461746528292C742E666F72456163682866756E6374696F6E2874297B6E5B745D2626286F2E72656D6F76654368696C6428';
wwv_flow_imp.g_varchar2_table(313) := '6E5B745D292C6F2E617070656E644368696C64286E5B745D29297D292C652626746869732E616E696D617465416C6C28297D2C736176653A66756E6374696F6E28297B76617220743D746869732E6F7074696F6E732E73746F72653B742626742E736574';
wwv_flow_imp.g_varchar2_table(314) := '2626742E7365742874686973297D2C636C6F736573743A66756E6374696F6E28742C65297B72657475726E205028742C657C7C746869732E6F7074696F6E732E647261676761626C652C746869732E656C2C2131297D2C6F7074696F6E3A66756E637469';
wwv_flow_imp.g_varchar2_table(315) := '6F6E28742C65297B766172206E3D746869732E6F7074696F6E733B696628766F696420303D3D3D652972657475726E206E5B745D3B766172206F3D472E6D6F646966794F7074696F6E28746869732C742C65293B6E5B745D3D766F69642030213D3D6F3F';
wwv_flow_imp.g_varchar2_table(316) := '6F3A652C2267726F7570223D3D3D7426265874286E297D2C64657374726F793A66756E6374696F6E28297B71282264657374726F79222C74686973293B76617220743D746869732E656C3B745B4B5D3D6E756C6C2C7028742C226D6F757365646F776E22';
wwv_flow_imp.g_varchar2_table(317) := '2C746869732E5F6F6E5461705374617274292C7028742C22746F7563687374617274222C746869732E5F6F6E5461705374617274292C7028742C22706F696E746572646F776E222C746869732E5F6F6E5461705374617274292C746869732E6E61746976';
wwv_flow_imp.g_varchar2_table(318) := '65447261676761626C652626287028742C22647261676F766572222C74686973292C7028742C2264726167656E746572222C7468697329292C41727261792E70726F746F747970652E666F72456163682E63616C6C28742E717565727953656C6563746F';
wwv_flow_imp.g_varchar2_table(319) := '72416C6C28225B647261676761626C655D22292C66756E6374696F6E2874297B742E72656D6F76654174747269627574652822647261676761626C6522297D292C746869732E5F6F6E44726F7028292C746869732E5F64697361626C6544656C61796564';
wwv_flow_imp.g_varchar2_table(320) := '447261674576656E747328292C5F742E73706C696365285F742E696E6465784F6628746869732E656C292C31292C746869732E656C3D743D6E756C6C7D2C5F68696465436C6F6E653A66756E6374696F6E28297B69747C7C2871282268696465436C6F6E';
wwv_flow_imp.g_varchar2_table(321) := '65222C74686973292C48742E6576656E7443616E63656C65647C7C2852286F742C22646973706C6179222C226E6F6E6522292C746869732E6F7074696F6E732E72656D6F7665436C6F6E654F6E4869646526266F742E706172656E744E6F646526266F74';
wwv_flow_imp.g_varchar2_table(322) := '2E706172656E744E6F64652E72656D6F76654368696C64286F74292C69743D213029297D2C5F73686F77436C6F6E653A66756E6374696F6E2874297B22636C6F6E65223D3D3D742E6C6173745075744D6F64653F697426262871282273686F77436C6F6E';
wwv_flow_imp.g_varchar2_table(323) := '65222C74686973292C48742E6576656E7443616E63656C65647C7C28242E706172656E744E6F6465213D74747C7C746869732E6F7074696F6E732E67726F75702E726576657274436C6F6E653F65743F74742E696E736572744265666F7265286F742C65';
wwv_flow_imp.g_varchar2_table(324) := '74293A74742E617070656E644368696C64286F74293A74742E696E736572744265666F7265286F742C24292C746869732E6F7074696F6E732E67726F75702E726576657274436C6F6E652626746869732E616E696D61746528242C6F74292C52286F742C';
wwv_flow_imp.g_varchar2_table(325) := '22646973706C6179222C2222292C69743D213129293A746869732E5F68696465436C6F6E6528297D7D2C417426266628646F63756D656E742C22746F7563686D6F7665222C66756E6374696F6E2874297B2848742E6163746976657C7C4574292626742E';
wwv_flow_imp.g_varchar2_table(326) := '63616E63656C61626C652626742E70726576656E7444656661756C7428297D292C48742E7574696C733D7B6F6E3A662C6F66663A702C6373733A522C66696E643A452C69733A66756E6374696F6E28742C65297B72657475726E21215028742C652C742C';
wwv_flow_imp.g_varchar2_table(327) := '2131297D2C657874656E643A66756E6374696F6E28742C65297B6966287426266529666F7228766172206E20696E206529652E6861734F776E50726F7065727479286E29262628745B6E5D3D655B6E5D293B72657475726E20747D2C7468726F74746C65';
wwv_flow_imp.g_varchar2_table(328) := '3A432C636C6F736573743A502C746F67676C65436C6173733A6B2C636C6F6E653A542C696E6465783A6A2C6E6578745469636B3A7A742C63616E63656C4E6578745469636B3A47742C646574656374446972656374696F6E3A52742C6765744368696C64';
wwv_flow_imp.g_varchar2_table(329) := '3A422C657870616E646F3A4B7D2C48742E6765743D66756E6374696F6E2874297B72657475726E20745B4B5D7D2C48742E6D6F756E743D66756E6374696F6E28297B666F722876617220743D617267756D656E74732E6C656E6774682C653D6E65772041';
wwv_flow_imp.g_varchar2_table(330) := '727261792874292C6E3D303B6E3C743B6E2B2B29655B6E5D3D617267756D656E74735B6E5D3B28653D655B305D2E636F6E7374727563746F723D3D3D41727261793F655B305D3A65292E666F72456163682866756E6374696F6E2874297B69662821742E';
wwv_flow_imp.g_varchar2_table(331) := '70726F746F747970657C7C21742E70726F746F747970652E636F6E7374727563746F72297468726F7722536F727461626C653A204D6F756E74656420706C7567696E206D757374206265206120636F6E7374727563746F722066756E6374696F6E2C206E';
wwv_flow_imp.g_varchar2_table(332) := '6F7420222E636F6E636174287B7D2E746F537472696E672E63616C6C287429293B742E7574696C7326262848742E7574696C733D492849287B7D2C48742E7574696C73292C742E7574696C7329292C472E6D6F756E742874297D297D2C48742E63726561';
wwv_flow_imp.g_varchar2_table(333) := '74653D66756E6374696F6E28742C65297B72657475726E206E657720487428742C65297D3B7661722055742C71742C56742C5A742C24742C51742C4A743D5B5D2C74653D212848742E76657273696F6E3D22312E31352E3722293B66756E6374696F6E20';
wwv_flow_imp.g_varchar2_table(334) := '656528297B4A742E666F72456163682866756E6374696F6E2874297B636C656172496E74657276616C28742E706964297D292C4A743D5B5D7D66756E6374696F6E206E6528297B636C656172496E74657276616C285174297D766172206F652C69653D43';
wwv_flow_imp.g_varchar2_table(335) := '2866756E6374696F6E286E2C742C652C6F297B696628742E7363726F6C6C297B76617220692C723D286E2E746F75636865733F6E2E746F75636865735B305D3A6E292E636C69656E74582C613D286E2E746F75636865733F6E2E746F75636865735B305D';
wwv_flow_imp.g_varchar2_table(336) := '3A6E292E636C69656E74592C6C3D742E7363726F6C6C53656E73697469766974792C733D742E7363726F6C6C53706565642C633D4F28292C753D21313B7174213D3D6526262871743D652C656528292C55743D742E7363726F6C6C2C693D742E7363726F';
wwv_flow_imp.g_varchar2_table(337) := '6C6C466E2C21303D3D3D557426262855743D4D28652C21302929293B76617220643D302C683D55743B646F7B76617220663D682C703D582866292C673D702E746F702C6D3D702E626F74746F6D2C763D702E6C6566742C623D702E72696768742C793D70';
wwv_flow_imp.g_varchar2_table(338) := '2E77696474682C773D702E6865696768742C443D766F696420302C453D766F696420302C533D662E7363726F6C6C57696474682C5F3D662E7363726F6C6C4865696768742C433D522866292C543D662E7363726F6C6C4C6566742C703D662E7363726F6C';
wwv_flow_imp.g_varchar2_table(339) := '6C546F702C453D663D3D3D633F28443D793C53262628226175746F223D3D3D432E6F766572666C6F77587C7C227363726F6C6C223D3D3D432E6F766572666C6F77587C7C2276697369626C65223D3D3D432E6F766572666C6F7758292C773C5F26262822';
wwv_flow_imp.g_varchar2_table(340) := '6175746F223D3D3D432E6F766572666C6F77597C7C227363726F6C6C223D3D3D432E6F766572666C6F77597C7C2276697369626C65223D3D3D432E6F766572666C6F775929293A28443D793C53262628226175746F223D3D3D432E6F766572666C6F7758';
wwv_flow_imp.g_varchar2_table(341) := '7C7C227363726F6C6C223D3D3D432E6F766572666C6F7758292C773C5F262628226175746F223D3D3D432E6F766572666C6F77597C7C227363726F6C6C223D3D3D432E6F766572666C6F775929292C543D442626284D6174682E61627328622D72293C3D';
wwv_flow_imp.g_varchar2_table(342) := '6C2626542B793C53292D284D6174682E61627328762D72293C3D6C2626212154292C703D452626284D6174682E616273286D2D61293C3D6C2626702B773C5F292D284D6174682E61627328672D61293C3D6C2626212170293B696628214A745B645D2966';
wwv_flow_imp.g_varchar2_table(343) := '6F722876617220783D303B783C3D643B782B2B294A745B785D7C7C284A745B785D3D7B7D293B4A745B645D2E76783D3D5426264A745B645D2E76793D3D7026264A745B645D2E656C3D3D3D667C7C284A745B645D2E656C3D662C4A745B645D2E76783D54';
wwv_flow_imp.g_varchar2_table(344) := '2C4A745B645D2E76793D702C636C656172496E74657276616C284A745B645D2E706964292C303D3D542626303D3D707C7C28753D21302C4A745B645D2E7069643D736574496E74657276616C2866756E6374696F6E28297B6F2626303D3D3D746869732E';
wwv_flow_imp.g_varchar2_table(345) := '6C61796572262648742E6163746976652E5F6F6E546F7563684D6F7665282474293B76617220743D4A745B746869732E6C617965725D2E76793F4A745B746869732E6C617965725D2E76792A733A302C653D4A745B746869732E6C617965725D2E76783F';
wwv_flow_imp.g_varchar2_table(346) := '4A745B746869732E6C617965725D2E76782A733A303B2266756E6374696F6E223D3D747970656F662069262622636F6E74696E756522213D3D692E63616C6C2848742E647261676765642E706172656E744E6F64655B4B5D2C652C742C6E2C24742C4A74';
wwv_flow_imp.g_varchar2_table(347) := '5B746869732E6C617965725D2E656C297C7C48284A745B746869732E6C617965725D2E656C2C652C74297D2E62696E64287B6C617965723A647D292C32342929292C642B2B7D7768696C6528742E627562626C655363726F6C6C262668213D3D63262628';
wwv_flow_imp.g_varchar2_table(348) := '683D4D28682C21312929293B74653D757D7D2C3330292C6E3D66756E6374696F6E2874297B76617220653D742E6F726967696E616C4576656E742C6E3D742E707574536F727461626C652C6F3D742E64726167456C2C693D742E616374697665536F7274';
wwv_flow_imp.g_varchar2_table(349) := '61626C652C723D742E6469737061746368536F727461626C654576656E742C613D742E6869646547686F7374466F725461726765742C743D742E756E6869646547686F7374466F725461726765743B65262628693D6E7C7C692C6128292C653D652E6368';
wwv_flow_imp.g_varchar2_table(350) := '616E676564546F75636865732626652E6368616E676564546F75636865732E6C656E6774683F652E6368616E676564546F75636865735B305D3A652C653D646F63756D656E742E656C656D656E7446726F6D506F696E7428652E636C69656E74582C652E';
wwv_flow_imp.g_varchar2_table(351) := '636C69656E7459292C7428292C69262621692E656C2E636F6E7461696E732865292626287228227370696C6C22292C746869732E6F6E5370696C6C287B64726167456C3A6F2C707574536F727461626C653A6E7D2929297D3B66756E6374696F6E207265';
wwv_flow_imp.g_varchar2_table(352) := '28297B7D66756E6374696F6E20616528297B7D72652E70726F746F747970653D7B7374617274496E6465783A6E756C6C2C6472616753746172743A66756E6374696F6E2874297B743D742E6F6C64447261676761626C65496E6465783B746869732E7374';
wwv_flow_imp.g_varchar2_table(353) := '617274496E6465783D747D2C6F6E5370696C6C3A66756E6374696F6E2874297B76617220653D742E64726167456C2C6E3D742E707574536F727461626C653B746869732E736F727461626C652E63617074757265416E696D6174696F6E53746174652829';
wwv_flow_imp.g_varchar2_table(354) := '2C6E26266E2E63617074757265416E696D6174696F6E537461746528293B743D4228746869732E736F727461626C652E656C2C746869732E7374617274496E6465782C746869732E6F7074696F6E73293B743F746869732E736F727461626C652E656C2E';
wwv_flow_imp.g_varchar2_table(355) := '696E736572744265666F726528652C74293A746869732E736F727461626C652E656C2E617070656E644368696C642865292C746869732E736F727461626C652E616E696D617465416C6C28292C6E26266E2E616E696D617465416C6C28297D2C64726F70';
wwv_flow_imp.g_varchar2_table(356) := '3A6E7D2C612872652C7B706C7567696E4E616D653A227265766572744F6E5370696C6C227D292C61652E70726F746F747970653D7B6F6E5370696C6C3A66756E6374696F6E2874297B76617220653D742E64726167456C2C743D742E707574536F727461';
wwv_flow_imp.g_varchar2_table(357) := '626C657C7C746869732E736F727461626C653B742E63617074757265416E696D6174696F6E537461746528292C652E706172656E744E6F64652626652E706172656E744E6F64652E72656D6F76654368696C642865292C742E616E696D617465416C6C28';
wwv_flow_imp.g_varchar2_table(358) := '297D2C64726F703A6E7D2C612861652C7B706C7567696E4E616D653A2272656D6F76654F6E5370696C6C227D293B766172206C652C73652C63652C75652C64652C68653D5B5D2C66653D5B5D2C70653D21312C67653D21312C6D653D21313B66756E6374';
wwv_flow_imp.g_varchar2_table(359) := '696F6E207665286E2C6F297B66652E666F72456163682866756E6374696F6E28742C65297B653D6F2E6368696C6472656E5B742E736F727461626C65496E6465782B286E3F4E756D6265722865293A30295D3B653F6F2E696E736572744265666F726528';
wwv_flow_imp.g_varchar2_table(360) := '742C65293A6F2E617070656E644368696C642874297D297D66756E6374696F6E20626528297B68652E666F72456163682866756E6374696F6E2874297B74213D3D63652626742E706172656E744E6F64652626742E706172656E744E6F64652E72656D6F';
wwv_flow_imp.g_varchar2_table(361) := '76654368696C642874297D297D72657475726E2048742E6D6F756E74286E65772066756E6374696F6E28297B66756E6374696F6E207428297B666F7228766172207420696E20746869732E64656661756C74733D7B7363726F6C6C3A21302C666F726365';
wwv_flow_imp.g_varchar2_table(362) := '4175746F5363726F6C6C46616C6C6261636B3A21312C7363726F6C6C53656E73697469766974793A33302C7363726F6C6C53706565643A31302C627562626C655363726F6C6C3A21307D2C7468697329225F223D3D3D742E636861724174283029262622';
wwv_flow_imp.g_varchar2_table(363) := '66756E6374696F6E223D3D747970656F6620746869735B745D262628746869735B745D3D746869735B745D2E62696E64287468697329297D72657475726E20742E70726F746F747970653D7B64726167537461727465643A66756E6374696F6E2874297B';
wwv_flow_imp.g_varchar2_table(364) := '743D742E6F726967696E616C4576656E743B746869732E736F727461626C652E6E6174697665447261676761626C653F6628646F63756D656E742C22647261676F766572222C746869732E5F68616E646C654175746F5363726F6C6C293A746869732E6F';
wwv_flow_imp.g_varchar2_table(365) := '7074696F6E732E737570706F7274506F696E7465723F6628646F63756D656E742C22706F696E7465726D6F7665222C746869732E5F68616E646C6546616C6C6261636B4175746F5363726F6C6C293A742E746F75636865733F6628646F63756D656E742C';
wwv_flow_imp.g_varchar2_table(366) := '22746F7563686D6F7665222C746869732E5F68616E646C6546616C6C6261636B4175746F5363726F6C6C293A6628646F63756D656E742C226D6F7573656D6F7665222C746869732E5F68616E646C6546616C6C6261636B4175746F5363726F6C6C297D2C';
wwv_flow_imp.g_varchar2_table(367) := '647261674F766572436F6D706C657465643A66756E6374696F6E2874297B743D742E6F726967696E616C4576656E743B746869732E6F7074696F6E732E647261674F766572427562626C657C7C742E726F6F74456C7C7C746869732E5F68616E646C6541';
wwv_flow_imp.g_varchar2_table(368) := '75746F5363726F6C6C2874297D2C64726F703A66756E6374696F6E28297B746869732E736F727461626C652E6E6174697665447261676761626C653F7028646F63756D656E742C22647261676F766572222C746869732E5F68616E646C654175746F5363';
wwv_flow_imp.g_varchar2_table(369) := '726F6C6C293A287028646F63756D656E742C22706F696E7465726D6F7665222C746869732E5F68616E646C6546616C6C6261636B4175746F5363726F6C6C292C7028646F63756D656E742C22746F7563686D6F7665222C746869732E5F68616E646C6546';
wwv_flow_imp.g_varchar2_table(370) := '616C6C6261636B4175746F5363726F6C6C292C7028646F63756D656E742C226D6F7573656D6F7665222C746869732E5F68616E646C6546616C6C6261636B4175746F5363726F6C6C29292C6E6528292C656528292C636C65617254696D656F7574287629';
wwv_flow_imp.g_varchar2_table(371) := '2C763D766F696420307D2C6E756C6C696E673A66756E6374696F6E28297B24743D71743D55743D74653D51743D56743D5A743D6E756C6C2C4A742E6C656E6774683D307D2C5F68616E646C6546616C6C6261636B4175746F5363726F6C6C3A66756E6374';
wwv_flow_imp.g_varchar2_table(372) := '696F6E2874297B746869732E5F68616E646C654175746F5363726F6C6C28742C2130297D2C5F68616E646C654175746F5363726F6C6C3A66756E6374696F6E28652C6E297B766172206F2C693D746869732C723D28652E746F75636865733F652E746F75';
wwv_flow_imp.g_varchar2_table(373) := '636865735B305D3A65292E636C69656E74582C613D28652E746F75636865733F652E746F75636865735B305D3A65292E636C69656E74592C743D646F63756D656E742E656C656D656E7446726F6D506F696E7428722C61293B24743D652C6E7C7C746869';
wwv_flow_imp.g_varchar2_table(374) := '732E6F7074696F6E732E666F7263654175746F5363726F6C6C46616C6C6261636B7C7C777C7C797C7C753F28696528652C746869732E6F7074696F6E732C742C6E292C6F3D4D28742C2130292C2174657C7C51742626723D3D3D56742626613D3D3D5A74';
wwv_flow_imp.g_varchar2_table(375) := '7C7C28517426266E6528292C51743D736574496E74657276616C2866756E6374696F6E28297B76617220743D4D28646F63756D656E742E656C656D656E7446726F6D506F696E7428722C61292C2130293B74213D3D6F2626286F3D742C65652829292C69';
wwv_flow_imp.g_varchar2_table(376) := '6528652C692E6F7074696F6E732C742C6E297D2C3130292C56743D722C5A743D6129293A746869732E6F7074696F6E732E627562626C655363726F6C6C26264D28742C213029213D3D4F28293F696528652C746869732E6F7074696F6E732C4D28742C21';
wwv_flow_imp.g_varchar2_table(377) := '31292C2131293A656528297D7D2C6128742C7B706C7567696E4E616D653A227363726F6C6C222C696E697469616C697A65427944656661756C743A21307D297D292C48742E6D6F756E742861652C7265292C48742E6D6F756E74286E65772066756E6374';
wwv_flow_imp.g_varchar2_table(378) := '696F6E28297B66756E6374696F6E207428297B746869732E64656661756C74733D7B73776170436C6173733A22736F727461626C652D737761702D686967686C69676874227D7D72657475726E20742E70726F746F747970653D7B647261675374617274';
wwv_flow_imp.g_varchar2_table(379) := '3A66756E6374696F6E2874297B743D742E64726167456C3B6F653D747D2C647261674F76657256616C69643A66756E6374696F6E2874297B76617220653D742E636F6D706C657465642C6E3D742E7461726765742C6F3D742E6F6E4D6F76652C693D742E';
wwv_flow_imp.g_varchar2_table(380) := '616374697665536F727461626C652C723D742E6368616E6765642C613D742E63616E63656C3B692E6F7074696F6E732E73776170262628743D746869732E736F727461626C652E656C2C693D746869732E6F7074696F6E732C6E26266E213D3D74262628';
wwv_flow_imp.g_varchar2_table(381) := '743D6F652C6F653D2131213D3D6F286E293F286B286E2C692E73776170436C6173732C2130292C6E293A6E756C6C2C74262674213D3D6F6526266B28742C692E73776170436C6173732C213129292C7228292C65282130292C612829297D2C64726F703A';
wwv_flow_imp.g_varchar2_table(382) := '66756E6374696F6E2874297B76617220652C6E2C6F3D742E616374697665536F727461626C652C693D742E707574536F727461626C652C723D742E64726167456C2C613D697C7C746869732E736F727461626C652C6C3D746869732E6F7074696F6E733B';
wwv_flow_imp.g_varchar2_table(383) := '6F6526266B286F652C6C2E73776170436C6173732C2131292C6F652626286C2E737761707C7C692626692E6F7074696F6E732E7377617029262672213D3D6F65262628612E63617074757265416E696D6174696F6E537461746528292C61213D3D6F2626';
wwv_flow_imp.g_varchar2_table(384) := '6F2E63617074757265416E696D6174696F6E537461746528292C6E3D6F652C743D28653D72292E706172656E744E6F64652C6C3D6E2E706172656E744E6F64652C7426266C262621742E6973457175616C4E6F6465286E292626216C2E6973457175616C';
wwv_flow_imp.g_varchar2_table(385) := '4E6F6465286529262628693D6A2865292C723D6A286E292C742E6973457175616C4E6F6465286C292626693C722626722B2B2C742E696E736572744265666F7265286E2C742E6368696C6472656E5B695D292C6C2E696E736572744265666F726528652C';
wwv_flow_imp.g_varchar2_table(386) := '6C2E6368696C6472656E5B725D29292C612E616E696D617465416C6C28292C61213D3D6F26266F2E616E696D617465416C6C2829297D2C6E756C6C696E673A66756E6374696F6E28297B6F653D6E756C6C7D7D2C6128742C7B706C7567696E4E616D653A';
wwv_flow_imp.g_varchar2_table(387) := '2273776170222C6576656E7450726F706572746965733A66756E6374696F6E28297B72657475726E7B737761704974656D3A6F657D7D7D297D292C48742E6D6F756E74286E65772066756E6374696F6E28297B66756E6374696F6E2074286F297B666F72';
wwv_flow_imp.g_varchar2_table(388) := '28766172207420696E207468697329225F223D3D3D742E63686172417428302926262266756E6374696F6E223D3D747970656F6620746869735B745D262628746869735B745D3D746869735B745D2E62696E64287468697329293B6F2E6F7074696F6E73';
wwv_flow_imp.g_varchar2_table(389) := '2E61766F6964496D706C69636974446573656C6563747C7C286F2E6F7074696F6E732E737570706F7274506F696E7465723F6628646F63756D656E742C22706F696E7465727570222C746869732E5F646573656C6563744D756C746944726167293A2866';
wwv_flow_imp.g_varchar2_table(390) := '28646F63756D656E742C226D6F7573657570222C746869732E5F646573656C6563744D756C746944726167292C6628646F63756D656E742C22746F756368656E64222C746869732E5F646573656C6563744D756C7469447261672929292C6628646F6375';
wwv_flow_imp.g_varchar2_table(391) := '6D656E742C226B6579646F776E222C746869732E5F636865636B4B6579446F776E292C6628646F63756D656E742C226B65797570222C746869732E5F636865636B4B65795570292C746869732E64656661756C74733D7B73656C6563746564436C617373';
wwv_flow_imp.g_varchar2_table(392) := '3A22736F727461626C652D73656C6563746564222C6D756C7469447261674B65793A6E756C6C2C61766F6964496D706C69636974446573656C6563743A21312C736574446174613A66756E6374696F6E28742C65297B766172206E3D22223B68652E6C65';
wwv_flow_imp.g_varchar2_table(393) := '6E677468262673653D3D3D6F3F68652E666F72456163682866756E6374696F6E28742C65297B6E2B3D28653F222C20223A2222292B742E74657874436F6E74656E747D293A6E3D652E74657874436F6E74656E742C742E73657444617461282254657874';
wwv_flow_imp.g_varchar2_table(394) := '222C6E297D7D7D72657475726E20742E70726F746F747970653D7B6D756C7469447261674B6579446F776E3A21312C69734D756C7469447261673A21312C64656C61795374617274476C6F62616C3A66756E6374696F6E2874297B743D742E6472616745';
wwv_flow_imp.g_varchar2_table(395) := '6C3B63653D747D2C64656C6179456E6465643A66756E6374696F6E28297B746869732E69734D756C7469447261673D7E68652E696E6465784F66286365297D2C7365747570436C6F6E653A66756E6374696F6E2874297B76617220653D742E736F727461';
wwv_flow_imp.g_varchar2_table(396) := '626C652C743D742E63616E63656C3B696628746869732E69734D756C746944726167297B666F7228766172206E3D303B6E3C68652E6C656E6774683B6E2B2B2966652E7075736828542868655B6E5D29292C66655B6E5D2E736F727461626C65496E6465';
wwv_flow_imp.g_varchar2_table(397) := '783D68655B6E5D2E736F727461626C65496E6465782C66655B6E5D2E647261676761626C653D21312C66655B6E5D2E7374796C655B2277696C6C2D6368616E6765225D3D22222C6B2866655B6E5D2C746869732E6F7074696F6E732E73656C6563746564';
wwv_flow_imp.g_varchar2_table(398) := '436C6173732C2131292C68655B6E5D3D3D3D636526266B2866655B6E5D2C746869732E6F7074696F6E732E63686F73656E436C6173732C2131293B652E5F68696465436C6F6E6528292C7428297D7D2C636C6F6E653A66756E6374696F6E2874297B7661';
wwv_flow_imp.g_varchar2_table(399) := '7220653D742E736F727461626C652C6E3D742E726F6F74456C2C6F3D742E6469737061746368536F727461626C654576656E742C743D742E63616E63656C3B746869732E69734D756C746944726167262628746869732E6F7074696F6E732E72656D6F76';
wwv_flow_imp.g_varchar2_table(400) := '65436C6F6E654F6E486964657C7C68652E6C656E677468262673653D3D3D6526262876652821302C6E292C6F2822636C6F6E6522292C74282929297D2C73686F77436C6F6E653A66756E6374696F6E2874297B76617220653D742E636C6F6E654E6F7753';
wwv_flow_imp.g_varchar2_table(401) := '686F776E2C6E3D742E726F6F74456C2C743D742E63616E63656C3B746869732E69734D756C74694472616726262876652821312C6E292C66652E666F72456163682866756E6374696F6E2874297B5228742C22646973706C6179222C2222297D292C6528';
wwv_flow_imp.g_varchar2_table(402) := '292C64653D21312C742829297D2C68696465436C6F6E653A66756E6374696F6E2874297B76617220653D746869732C6E3D28742E736F727461626C652C742E636C6F6E654E6F7748696464656E292C743D742E63616E63656C3B746869732E69734D756C';
wwv_flow_imp.g_varchar2_table(403) := '74694472616726262866652E666F72456163682866756E6374696F6E2874297B5228742C22646973706C6179222C226E6F6E6522292C652E6F7074696F6E732E72656D6F7665436C6F6E654F6E486964652626742E706172656E744E6F64652626742E70';
wwv_flow_imp.g_varchar2_table(404) := '6172656E744E6F64652E72656D6F76654368696C642874297D292C6E28292C64653D21302C742829297D2C647261675374617274476C6F62616C3A66756E6374696F6E2874297B742E736F727461626C653B21746869732E69734D756C74694472616726';
wwv_flow_imp.g_varchar2_table(405) := '267365262673652E6D756C7469447261672E5F646573656C6563744D756C74694472616728292C68652E666F72456163682866756E6374696F6E2874297B742E736F727461626C65496E6465783D6A2874297D292C68653D68652E736F72742866756E63';
wwv_flow_imp.g_varchar2_table(406) := '74696F6E28742C65297B72657475726E20742E736F727461626C65496E6465782D652E736F727461626C65496E6465787D292C6D653D21307D2C64726167537461727465643A66756E6374696F6E2874297B76617220652C6E3D746869732C743D742E73';
wwv_flow_imp.g_varchar2_table(407) := '6F727461626C653B746869732E69734D756C746944726167262628746869732E6F7074696F6E732E736F7274262628742E63617074757265416E696D6174696F6E537461746528292C746869732E6F7074696F6E732E616E696D6174696F6E2626286865';
wwv_flow_imp.g_varchar2_table(408) := '2E666F72456163682866756E6374696F6E2874297B74213D3D636526265228742C22706F736974696F6E222C226162736F6C75746522297D292C653D582863652C21312C21302C2130292C68652E666F72456163682866756E6374696F6E2874297B7421';
wwv_flow_imp.g_varchar2_table(409) := '3D3D636526267828742C65297D292C70653D67653D213029292C742E616E696D617465416C6C2866756E6374696F6E28297B70653D67653D21312C6E2E6F7074696F6E732E616E696D6174696F6E262668652E666F72456163682866756E6374696F6E28';
wwv_flow_imp.g_varchar2_table(410) := '74297B412874297D292C6E2E6F7074696F6E732E736F72742626626528297D29297D2C647261674F7665723A66756E6374696F6E2874297B76617220653D742E7461726765742C6E3D742E636F6D706C657465642C743D742E63616E63656C3B67652626';
wwv_flow_imp.g_varchar2_table(411) := '7E68652E696E6465784F662865292626286E282131292C742829297D2C7265766572743A66756E6374696F6E2874297B766172206E2C6F2C653D742E66726F6D536F727461626C652C693D742E726F6F74456C2C723D742E736F727461626C652C613D74';
wwv_flow_imp.g_varchar2_table(412) := '2E64726167526563743B313C68652E6C656E67746826262868652E666F72456163682866756E6374696F6E2874297B722E616464416E696D6174696F6E5374617465287B7461726765743A742C726563743A67653F582874293A617D292C412874292C74';
wwv_flow_imp.g_varchar2_table(413) := '2E66726F6D526563743D612C652E72656D6F7665416E696D6174696F6E53746174652874297D292C67653D21312C6E3D21746869732E6F7074696F6E732E72656D6F7665436C6F6E654F6E486964652C6F3D692C68652E666F72456163682866756E6374';
wwv_flow_imp.g_varchar2_table(414) := '696F6E28742C65297B653D6F2E6368696C6472656E5B742E736F727461626C65496E6465782B286E3F4E756D6265722865293A30295D3B653F6F2E696E736572744265666F726528742C65293A6F2E617070656E644368696C642874297D29297D2C6472';
wwv_flow_imp.g_varchar2_table(415) := '61674F766572436F6D706C657465643A66756E6374696F6E2874297B76617220652C6E3D742E736F727461626C652C6F3D742E69734F776E65722C693D742E696E73657274696F6E2C723D742E616374697665536F727461626C652C613D742E70617265';
wwv_flow_imp.g_varchar2_table(416) := '6E74456C2C6C3D742E707574536F727461626C652C743D746869732E6F7074696F6E733B692626286F2626722E5F68696465436C6F6E6528292C70653D21312C742E616E696D6174696F6E2626313C68652E6C656E67746826262867657C7C216F262621';
wwv_flow_imp.g_varchar2_table(417) := '722E6F7074696F6E732E736F72742626216C29262628653D582863652C21312C21302C2130292C68652E666F72456163682866756E6374696F6E2874297B74213D3D63652626287828742C65292C612E617070656E644368696C64287429297D292C6765';
wwv_flow_imp.g_varchar2_table(418) := '3D2130292C6F7C7C2867657C7C626528292C313C68652E6C656E6774683F286F3D64652C722E5F73686F77436C6F6E65286E292C722E6F7074696F6E732E616E696D6174696F6E262621646526266F262666652E666F72456163682866756E6374696F6E';
wwv_flow_imp.g_varchar2_table(419) := '2874297B722E616464416E696D6174696F6E5374617465287B7461726765743A742C726563743A75657D292C742E66726F6D526563743D75652C742E74686973416E696D6174696F6E4475726174696F6E3D6E756C6C7D29293A722E5F73686F77436C6F';
wwv_flow_imp.g_varchar2_table(420) := '6E65286E2929297D2C647261674F766572416E696D6174696F6E436170747572653A66756E6374696F6E2874297B76617220653D742E64726167526563742C6E3D742E69734F776E65722C743D742E616374697665536F727461626C653B68652E666F72';
wwv_flow_imp.g_varchar2_table(421) := '456163682866756E6374696F6E2874297B742E74686973416E696D6174696F6E4475726174696F6E3D6E756C6C7D292C742E6F7074696F6E732E616E696D6174696F6E2626216E2626742E6D756C7469447261672E69734D756C74694472616726262875';
wwv_flow_imp.g_varchar2_table(422) := '653D61287B7D2C65292C653D442863652C2130292C75652E746F702D3D652E662C75652E6C6566742D3D652E65297D2C647261674F766572416E696D6174696F6E436F6D706C6574653A66756E6374696F6E28297B676526262867653D21312C62652829';
wwv_flow_imp.g_varchar2_table(423) := '297D2C64726F703A66756E6374696F6E2874297B766172206F2C692C722C612C6E2C652C6C2C733D742E6F726967696E616C4576656E742C633D742E726F6F74456C2C753D742E706172656E74456C2C643D742E736F727461626C652C683D742E646973';
wwv_flow_imp.g_varchar2_table(424) := '7061746368536F727461626C654576656E742C663D742E6F6C64496E6465782C743D742E707574536F727461626C652C703D747C7C746869732E736F727461626C653B732626286F3D746869732E6F7074696F6E732C693D752E6368696C6472656E2C6D';
wwv_flow_imp.g_varchar2_table(425) := '657C7C286F2E6D756C7469447261674B6579262621746869732E6D756C7469447261674B6579446F776E2626746869732E5F646573656C6563744D756C74694472616728292C6B2863652C6F2E73656C6563746564436C6173732C217E68652E696E6465';
wwv_flow_imp.g_varchar2_table(426) := '784F6628636529292C7E68652E696E6465784F66286365293F2868652E73706C6963652868652E696E6465784F66286365292C31292C6C653D6E756C6C2C55287B736F727461626C653A642C726F6F74456C3A632C6E616D653A22646573656C65637422';
wwv_flow_imp.g_varchar2_table(427) := '2C746172676574456C3A63652C6F726967696E616C4576656E743A737D29293A2868652E70757368286365292C55287B736F727461626C653A642C726F6F74456C3A632C6E616D653A2273656C656374222C746172676574456C3A63652C6F726967696E';
wwv_flow_imp.g_varchar2_table(428) := '616C4576656E743A737D292C732E73686966744B657926266C652626642E656C2E636F6E7461696E73286C65293F28723D6A286C65292C613D6A286365292C7E7226267E61262672213D3D61262666756E6374696F6E28297B666F722876617220652C74';
wwv_flow_imp.g_varchar2_table(429) := '3D723C613F28653D722C61293A28653D612C722B31292C6E3D6F2E66696C7465723B653C743B652B2B297E68652E696E6465784F6628695B655D297C7C5028695B655D2C6F2E647261676761626C652C752C2131292626286E2626282266756E6374696F';
wwv_flow_imp.g_varchar2_table(430) := '6E223D3D747970656F66206E3F6E2E63616C6C28642C732C695B655D2C64293A6E2E73706C697428222C22292E736F6D652866756E6374696F6E2874297B72657475726E205028695B655D2C742E7472696D28292C752C2131297D29297C7C286B28695B';
wwv_flow_imp.g_varchar2_table(431) := '655D2C6F2E73656C6563746564436C6173732C2130292C68652E7075736828695B655D292C55287B736F727461626C653A642C726F6F74456C3A632C6E616D653A2273656C656374222C746172676574456C3A695B655D2C6F726967696E616C4576656E';
wwv_flow_imp.g_varchar2_table(432) := '743A737D2929297D2829293A6C653D63652C73653D7029292C6D652626746869732E69734D756C74694472616726262867653D21312C28755B4B5D2E6F7074696F6E732E736F72747C7C75213D3D63292626313C68652E6C656E6774682626286E3D5828';
wwv_flow_imp.g_varchar2_table(433) := '6365292C653D6A2863652C223A6E6F74282E222B746869732E6F7074696F6E732E73656C6563746564436C6173732B222922292C21706526266F2E616E696D6174696F6E26262863652E74686973416E696D6174696F6E4475726174696F6E3D6E756C6C';
wwv_flow_imp.g_varchar2_table(434) := '292C702E63617074757265416E696D6174696F6E537461746528292C70657C7C286F2E616E696D6174696F6E26262863652E66726F6D526563743D6E2C68652E666F72456163682866756E6374696F6E2874297B76617220653B742E74686973416E696D';
wwv_flow_imp.g_varchar2_table(435) := '6174696F6E4475726174696F6E3D6E756C6C2C74213D3D6365262628653D67653F582874293A6E2C742E66726F6D526563743D652C702E616464416E696D6174696F6E5374617465287B7461726765743A742C726563743A657D29297D29292C62652829';
wwv_flow_imp.g_varchar2_table(436) := '2C68652E666F72456163682866756E6374696F6E2874297B695B655D3F752E696E736572744265666F726528742C695B655D293A752E617070656E644368696C642874292C652B2B7D292C663D3D3D6A286365292626286C3D21312C68652E666F724561';
wwv_flow_imp.g_varchar2_table(437) := '63682866756E6374696F6E2874297B742E736F727461626C65496E646578213D3D6A2874292626286C3D2130297D292C6C26262868282275706461746522292C682822736F727422292929292C68652E666F72456163682866756E6374696F6E2874297B';
wwv_flow_imp.g_varchar2_table(438) := '412874297D292C702E616E696D617465416C6C2829292C73653D70292C28633D3D3D757C7C74262622636C6F6E6522213D3D742E6C6173745075744D6F646529262666652E666F72456163682866756E6374696F6E2874297B742E706172656E744E6F64';
wwv_flow_imp.g_varchar2_table(439) := '652626742E706172656E744E6F64652E72656D6F76654368696C642874297D29297D2C6E756C6C696E67476C6F62616C3A66756E6374696F6E28297B746869732E69734D756C7469447261673D6D653D21312C66652E6C656E6774683D307D2C64657374';
wwv_flow_imp.g_varchar2_table(440) := '726F79476C6F62616C3A66756E6374696F6E28297B746869732E5F646573656C6563744D756C74694472616728292C7028646F63756D656E742C22706F696E7465727570222C746869732E5F646573656C6563744D756C746944726167292C7028646F63';
wwv_flow_imp.g_varchar2_table(441) := '756D656E742C226D6F7573657570222C746869732E5F646573656C6563744D756C746944726167292C7028646F63756D656E742C22746F756368656E64222C746869732E5F646573656C6563744D756C746944726167292C7028646F63756D656E742C22';
wwv_flow_imp.g_varchar2_table(442) := '6B6579646F776E222C746869732E5F636865636B4B6579446F776E292C7028646F63756D656E742C226B65797570222C746869732E5F636865636B4B65795570297D2C5F646573656C6563744D756C7469447261673A66756E6374696F6E2874297B6966';
wwv_flow_imp.g_varchar2_table(443) := '282128766F69642030213D3D6D6526266D657C7C7365213D3D746869732E736F727461626C657C7C7426265028742E7461726765742C746869732E6F7074696F6E732E647261676761626C652C746869732E736F727461626C652E656C2C2131297C7C74';
wwv_flow_imp.g_varchar2_table(444) := '262630213D3D742E627574746F6E2929666F72283B68652E6C656E6774683B297B76617220653D68655B305D3B6B28652C746869732E6F7074696F6E732E73656C6563746564436C6173732C2131292C68652E736869667428292C55287B736F72746162';
wwv_flow_imp.g_varchar2_table(445) := '6C653A746869732E736F727461626C652C726F6F74456C3A746869732E736F727461626C652E656C2C6E616D653A22646573656C656374222C746172676574456C3A652C6F726967696E616C4576656E743A747D297D7D2C5F636865636B4B6579446F77';
wwv_flow_imp.g_varchar2_table(446) := '6E3A66756E6374696F6E2874297B742E6B65793D3D3D746869732E6F7074696F6E732E6D756C7469447261674B6579262628746869732E6D756C7469447261674B6579446F776E3D2130297D2C5F636865636B4B657955703A66756E6374696F6E287429';
wwv_flow_imp.g_varchar2_table(447) := '7B742E6B65793D3D3D746869732E6F7074696F6E732E6D756C7469447261674B6579262628746869732E6D756C7469447261674B6579446F776E3D2131297D7D2C6128742C7B706C7567696E4E616D653A226D756C746944726167222C7574696C733A7B';
wwv_flow_imp.g_varchar2_table(448) := '73656C6563743A66756E6374696F6E2874297B76617220653D742E706172656E744E6F64655B4B5D3B652626652E6F7074696F6E732E6D756C7469447261672626217E68652E696E6465784F66287429262628736526267365213D3D6526262873652E6D';
wwv_flow_imp.g_varchar2_table(449) := '756C7469447261672E5F646573656C6563744D756C74694472616728292C73653D65292C6B28742C652E6F7074696F6E732E73656C6563746564436C6173732C2130292C68652E70757368287429297D2C646573656C6563743A66756E6374696F6E2874';
wwv_flow_imp.g_varchar2_table(450) := '297B76617220653D742E706172656E744E6F64655B4B5D2C6E3D68652E696E6465784F662874293B652626652E6F7074696F6E732E6D756C74694472616726267E6E2626286B28742C652E6F7074696F6E732E73656C6563746564436C6173732C213129';
wwv_flow_imp.g_varchar2_table(451) := '2C68652E73706C696365286E2C3129297D7D2C6576656E7450726F706572746965733A66756E6374696F6E28297B766172206E3D746869732C6F3D5B5D2C693D5B5D3B72657475726E2068652E666F72456163682866756E6374696F6E2874297B766172';
wwv_flow_imp.g_varchar2_table(452) := '20653B6F2E70757368287B6D756C746944726167456C656D656E743A742C696E6465783A742E736F727461626C65496E6465787D292C653D6765262674213D3D63653F2D313A67653F6A28742C223A6E6F74282E222B6E2E6F7074696F6E732E73656C65';
wwv_flow_imp.g_varchar2_table(453) := '63746564436C6173732B222922293A6A2874292C692E70757368287B6D756C746944726167456C656D656E743A742C696E6465783A657D297D292C7B6974656D733A65286865292C636C6F6E65733A5B5D2E636F6E636174286665292C6F6C64496E6469';
wwv_flow_imp.g_varchar2_table(454) := '636965733A6F2C6E6577496E6469636965733A697D7D2C6F7074696F6E4C697374656E6572733A7B6D756C7469447261674B65793A66756E6374696F6E2874297B72657475726E226374726C223D3D3D28743D742E746F4C6F776572436173652829293F';
wwv_flow_imp.g_varchar2_table(455) := '743D22436F6E74726F6C223A313C742E6C656E677468262628743D742E6368617241742830292E746F55707065724361736528292B742E737562737472283129292C747D7D7D297D292C48747D293B';
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(735123448070069709)
,p_plugin_id=>wwv_flow_imp.id(732552980942701141)
,p_file_name=>'sortablejs.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '2F2A2120536F727461626C6520312E31352E37202D204D4954207C206769743A2F2F6769746875622E636F6D2F536F727461626C654A532F536F727461626C652E676974202A2F0A2166756E6374696F6E28742C65297B226F626A656374223D3D747970';
wwv_flow_imp.g_varchar2_table(2) := '656F66206578706F727473262622756E646566696E656422213D747970656F66206D6F64756C653F6D6F64756C652E6578706F7274733D6528293A2266756E6374696F6E223D3D747970656F6620646566696E652626646566696E652E616D643F646566';
wwv_flow_imp.g_varchar2_table(3) := '696E652865293A28743D747C7C73656C66292E536F727461626C653D6528297D28746869732C2866756E6374696F6E28297B2275736520737472696374223B66756E6374696F6E207428742C65297B286E756C6C3D3D657C7C653E742E6C656E67746829';
wwv_flow_imp.g_varchar2_table(4) := '262628653D742E6C656E677468293B666F7228766172206E3D302C6F3D41727261792865293B6E3C653B6E2B2B296F5B6E5D3D745B6E5D3B72657475726E206F7D66756E6374696F6E206528742C652C6E297B72657475726E28653D66756E6374696F6E';
wwv_flow_imp.g_varchar2_table(5) := '2874297B72657475726E20743D66756E6374696F6E28742C65297B696628226F626A65637422213D747970656F6620747C7C21742972657475726E20743B766172206E3D745B53796D626F6C2E746F5072696D69746976655D3B696628766F696420303D';
wwv_flow_imp.g_varchar2_table(6) := '3D3D6E2972657475726E2822737472696E67223D3D3D653F537472696E673A4E756D626572292874293B696628226F626A65637422213D747970656F6628653D6E2E63616C6C28742C657C7C2264656661756C742229292972657475726E20653B746872';
wwv_flow_imp.g_varchar2_table(7) := '6F77206E657720547970654572726F7228224040746F5072696D6974697665206D7573742072657475726E2061207072696D69746976652076616C75652E22297D28742C22737472696E6722292C2273796D626F6C223D3D747970656F6620743F743A74';
wwv_flow_imp.g_varchar2_table(8) := '2B22227D28652929696E20743F4F626A6563742E646566696E6550726F706572747928742C652C7B76616C75653A6E2C656E756D657261626C653A21302C636F6E666967757261626C653A21302C7772697461626C653A21307D293A745B655D3D6E2C74';
wwv_flow_imp.g_varchar2_table(9) := '7D66756E6374696F6E206E28297B72657475726E286E3D4F626A6563742E61737369676E3F4F626A6563742E61737369676E2E62696E6428293A66756E6374696F6E2874297B666F722876617220653D313B653C617267756D656E74732E6C656E677468';
wwv_flow_imp.g_varchar2_table(10) := '3B652B2B297B766172206E2C6F3D617267756D656E74735B655D3B666F72286E20696E206F29217B7D2E6861734F776E50726F70657274792E63616C6C286F2C6E297C7C28745B6E5D3D6F5B6E5D297D72657475726E20747D292E6170706C79286E756C';
wwv_flow_imp.g_varchar2_table(11) := '6C2C617267756D656E7473297D66756E6374696F6E206F28742C65297B766172206E2C6F3D4F626A6563742E6B6579732874293B72657475726E204F626A6563742E6765744F776E50726F706572747953796D626F6C732626286E3D4F626A6563742E67';
wwv_flow_imp.g_varchar2_table(12) := '65744F776E50726F706572747953796D626F6C732874292C652626286E3D6E2E66696C746572282866756E6374696F6E2865297B72657475726E204F626A6563742E6765744F776E50726F706572747944657363726970746F7228742C65292E656E756D';
wwv_flow_imp.g_varchar2_table(13) := '657261626C657D2929292C6F2E707573682E6170706C79286F2C6E29292C6F7D66756E6374696F6E20692874297B666F7228766172206E3D313B6E3C617267756D656E74732E6C656E6774683B6E2B2B297B76617220693D6E756C6C213D617267756D65';
wwv_flow_imp.g_varchar2_table(14) := '6E74735B6E5D3F617267756D656E74735B6E5D3A7B7D3B6E25323F6F284F626A6563742869292C2130292E666F7245616368282866756E6374696F6E286E297B6528742C6E2C695B6E5D297D29293A4F626A6563742E6765744F776E50726F7065727479';
wwv_flow_imp.g_varchar2_table(15) := '44657363726970746F72733F4F626A6563742E646566696E6550726F7065727469657328742C4F626A6563742E6765744F776E50726F706572747944657363726970746F7273286929293A6F284F626A656374286929292E666F7245616368282866756E';
wwv_flow_imp.g_varchar2_table(16) := '6374696F6E2865297B4F626A6563742E646566696E6550726F706572747928742C652C4F626A6563742E6765744F776E50726F706572747944657363726970746F7228692C6529297D29297D72657475726E20747D66756E6374696F6E20722865297B72';
wwv_flow_imp.g_varchar2_table(17) := '657475726E2066756E6374696F6E2865297B69662841727261792E697341727261792865292972657475726E20742865297D2865297C7C66756E6374696F6E2874297B69662822756E646566696E656422213D747970656F662053796D626F6C26266E75';
wwv_flow_imp.g_varchar2_table(18) := '6C6C213D745B53796D626F6C2E6974657261746F725D7C7C6E756C6C213D745B2240406974657261746F72225D2972657475726E2041727261792E66726F6D2874297D2865297C7C66756E6374696F6E28652C6E297B69662865297B6966282273747269';
wwv_flow_imp.g_varchar2_table(19) := '6E67223D3D747970656F6620652972657475726E207428652C6E293B766172206F3D7B7D2E746F537472696E672E63616C6C2865292E736C69636528382C2D31293B72657475726E224D6170223D3D3D286F3D224F626A656374223D3D3D6F2626652E63';
wwv_flow_imp.g_varchar2_table(20) := '6F6E7374727563746F723F652E636F6E7374727563746F722E6E616D653A6F297C7C22536574223D3D3D6F3F41727261792E66726F6D2865293A22417267756D656E7473223D3D3D6F7C7C2F5E283F3A55697C49296E74283F3A387C31367C333229283F';
wwv_flow_imp.g_varchar2_table(21) := '3A436C616D706564293F4172726179242F2E74657374286F293F7428652C6E293A766F696420307D7D2865297C7C66756E6374696F6E28297B7468726F77206E657720547970654572726F722822496E76616C696420617474656D707420746F20737072';
wwv_flow_imp.g_varchar2_table(22) := '656164206E6F6E2D6974657261626C6520696E7374616E63652E5C6E496E206F7264657220746F206265206974657261626C652C206E6F6E2D6172726179206F626A65637473206D75737420686176652061205B53796D626F6C2E6974657261746F725D';
wwv_flow_imp.g_varchar2_table(23) := '2829206D6574686F642E22297D28297D66756E6374696F6E20612874297B72657475726E28613D2266756E6374696F6E223D3D747970656F662053796D626F6C26262273796D626F6C223D3D747970656F662053796D626F6C2E6974657261746F723F66';
wwv_flow_imp.g_varchar2_table(24) := '756E6374696F6E2874297B72657475726E20747970656F6620747D3A66756E6374696F6E2874297B72657475726E207426262266756E6374696F6E223D3D747970656F662053796D626F6C2626742E636F6E7374727563746F723D3D3D53796D626F6C26';
wwv_flow_imp.g_varchar2_table(25) := '2674213D3D53796D626F6C2E70726F746F747970653F2273796D626F6C223A747970656F6620747D292874297D66756E6374696F6E206C2874297B69662822756E646566696E656422213D747970656F662077696E646F77262677696E646F772E6E6176';
wwv_flow_imp.g_varchar2_table(26) := '696761746F722972657475726E21216E6176696761746F722E757365724167656E742E6D617463682874297D76617220733D6C282F283F3A54726964656E742E2A72765B203A5D3F31315C2E7C6D7369657C69656D6F62696C657C57696E646F77732050';
wwv_flow_imp.g_varchar2_table(27) := '686F6E65292F69292C633D6C282F456467652F69292C753D6C282F66697265666F782F69292C643D6C282F7361666172692F69292626216C282F6368726F6D652F69292626216C282F616E64726F69642F69292C683D6C282F69502861647C6F647C686F';
wwv_flow_imp.g_varchar2_table(28) := '6E65292F69292C703D6C282F6368726F6D652F692926266C282F616E64726F69642F69292C663D7B636170747572653A21312C706173736976653A21317D3B66756E6374696F6E206728742C652C6E297B742E6164644576656E744C697374656E657228';
wwv_flow_imp.g_varchar2_table(29) := '652C6E2C2173262666297D66756E6374696F6E206D28742C652C6E297B742E72656D6F76654576656E744C697374656E657228652C6E2C2173262666297D66756E6374696F6E207628742C65297B69662865262628223E223D3D3D655B305D262628653D';
wwv_flow_imp.g_varchar2_table(30) := '652E737562737472696E67283129292C7429297472797B696628742E6D6174636865732972657475726E20742E6D6174636865732865293B696628742E6D734D61746368657353656C6563746F722972657475726E20742E6D734D61746368657353656C';
wwv_flow_imp.g_varchar2_table(31) := '6563746F722865293B696628742E7765626B69744D61746368657353656C6563746F722972657475726E20742E7765626B69744D61746368657353656C6563746F722865297D63617463682874297B72657475726E7D7D66756E6374696F6E2062287429';
wwv_flow_imp.g_varchar2_table(32) := '7B72657475726E20742E686F7374262674213D3D646F63756D656E742626742E686F73742E6E6F6465547970652626742E686F7374213D3D743F742E686F73743A742E706172656E744E6F64657D66756E6374696F6E207928742C652C6E2C6F297B6966';
wwv_flow_imp.g_varchar2_table(33) := '2874297B6E3D6E7C7C646F63756D656E743B646F7B6966286E756C6C213D65262628223E22213D3D655B305D7C7C742E706172656E744E6F64653D3D3D6E2926267628742C65297C7C6F2626743D3D3D6E2972657475726E20747D7768696C652874213D';
wwv_flow_imp.g_varchar2_table(34) := '3D6E262628743D6228742929297D72657475726E206E756C6C7D76617220772C443D2F5C732B2F673B66756E6374696F6E204528742C652C6E297B766172206F3B74262665262628742E636C6173734C6973743F742E636C6173734C6973745B6E3F2261';
wwv_flow_imp.g_varchar2_table(35) := '6464223A2272656D6F7665225D2865293A286F3D282220222B742E636C6173734E616D652B222022292E7265706C61636528442C222022292E7265706C616365282220222B652B2220222C222022292C742E636C6173734E616D653D286F2B286E3F2220';
wwv_flow_imp.g_varchar2_table(36) := '222B653A222229292E7265706C61636528442C2220222929297D66756E6374696F6E205328742C652C6E297B766172206F3D742626742E7374796C653B6966286F297B696628766F696420303D3D3D6E2972657475726E20646F63756D656E742E646566';
wwv_flow_imp.g_varchar2_table(37) := '61756C74566965772626646F63756D656E742E64656661756C74566965772E676574436F6D70757465645374796C653F6E3D646F63756D656E742E64656661756C74566965772E676574436F6D70757465645374796C6528742C2222293A742E63757272';
wwv_flow_imp.g_varchar2_table(38) := '656E745374796C652626286E3D742E63757272656E745374796C65292C766F696420303D3D3D653F6E3A6E5B655D3B6F5B653D6520696E206F7C7C2D31213D3D652E696E6465784F6628227765626B697422293F653A222D7765626B69742D222B655D3D';
wwv_flow_imp.g_varchar2_table(39) := '6E2B2822737472696E67223D3D747970656F66206E3F22223A22707822297D7D66756E6374696F6E205F28742C65297B766172206E3D22223B69662822737472696E67223D3D747970656F662074296E3D743B656C736520646F7B766172206F3D532874';
wwv_flow_imp.g_varchar2_table(40) := '2C227472616E73666F726D22297D7768696C65286F2626226E6F6E6522213D3D6F2626286E3D6F2B2220222B6E292C2165262628743D742E706172656E744E6F646529293B76617220693D77696E646F772E444F4D4D61747269787C7C77696E646F772E';
wwv_flow_imp.g_varchar2_table(41) := '5765624B69744353534D61747269787C7C77696E646F772E4353534D61747269787C7C77696E646F772E4D534353534D61747269783B72657475726E206926266E65772069286E297D66756E6374696F6E204328742C652C6E297B69662874297B766172';
wwv_flow_imp.g_varchar2_table(42) := '206F3D742E676574456C656D656E747342795461674E616D652865292C693D302C723D6F2E6C656E6774683B6966286E29666F72283B693C723B692B2B296E286F5B695D2C69293B72657475726E206F7D72657475726E5B5D7D66756E6374696F6E2054';
wwv_flow_imp.g_varchar2_table(43) := '28297B72657475726E20646F63756D656E742E7363726F6C6C696E67456C656D656E747C7C646F63756D656E742E646F63756D656E74456C656D656E747D66756E6374696F6E207828742C652C6E2C6F2C69297B696628742E676574426F756E64696E67';
wwv_flow_imp.g_varchar2_table(44) := '436C69656E74526563747C7C743D3D3D77696E646F77297B76617220722C612C6C2C632C752C642C683D74213D3D77696E646F772626742E706172656E744E6F6465262674213D3D5428293F28613D28723D742E676574426F756E64696E67436C69656E';
wwv_flow_imp.g_varchar2_table(45) := '74526563742829292E746F702C6C3D722E6C6566742C633D722E626F74746F6D2C753D722E72696768742C643D722E6865696768742C722E7769647468293A286C3D613D302C633D77696E646F772E696E6E65724865696768742C753D77696E646F772E';
wwv_flow_imp.g_varchar2_table(46) := '696E6E657257696474682C643D77696E646F772E696E6E65724865696768742C77696E646F772E696E6E65725769647468293B69662828657C7C6E29262674213D3D77696E646F77262628693D697C7C742E706172656E744E6F64652C21732929646F7B';
wwv_flow_imp.g_varchar2_table(47) := '696628692626692E676574426F756E64696E67436C69656E7452656374262628226E6F6E6522213D3D5328692C227472616E73666F726D22297C7C6E26262273746174696322213D3D5328692C22706F736974696F6E222929297B76617220703D692E67';
wwv_flow_imp.g_varchar2_table(48) := '6574426F756E64696E67436C69656E745265637428293B612D3D702E746F702B7061727365496E74285328692C22626F726465722D746F702D77696474682229292C6C2D3D702E6C6566742B7061727365496E74285328692C22626F726465722D6C6566';
wwv_flow_imp.g_varchar2_table(49) := '742D77696474682229292C633D612B722E6865696768742C753D6C2B722E77696474683B627265616B7D7D7768696C6528693D692E706172656E744E6F6465293B72657475726E206F262674213D3D77696E646F772626286F3D28653D5F28697C7C7429';
wwv_flow_imp.g_varchar2_table(50) := '292626652E612C743D652626652E642C65262628633D28612F3D74292B28642F3D74292C753D286C2F3D6F292B28682F3D6F2929292C7B746F703A612C6C6566743A6C2C626F74746F6D3A632C72696768743A752C77696474683A682C6865696768743A';
wwv_flow_imp.g_varchar2_table(51) := '647D7D7D66756E6374696F6E204F28742C652C6E297B666F7228766172206F3D5028742C2130292C693D782874295B655D3B6F3B297B76617220723D78286F295B6E5D3B696628212822746F70223D3D3D6E7C7C226C656674223D3D3D6E3F723C3D693A';
wwv_flow_imp.g_varchar2_table(52) := '693C3D72292972657475726E206F3B6966286F3D3D3D54282929627265616B3B6F3D50286F2C2131297D72657475726E21317D66756E6374696F6E204D28742C652C6E2C6F297B666F722876617220693D302C723D302C613D742E6368696C6472656E3B';
wwv_flow_imp.g_varchar2_table(53) := '723C612E6C656E6774683B297B696628226E6F6E6522213D3D615B725D2E7374796C652E646973706C61792626615B725D213D3D46742E67686F73742626286F7C7C615B725D213D3D46742E647261676765642926267928615B725D2C6E2E6472616767';
wwv_flow_imp.g_varchar2_table(54) := '61626C652C742C213129297B696628693D3D3D652972657475726E20615B725D3B692B2B7D722B2B7D72657475726E206E756C6C7D66756E6374696F6E204128742C65297B666F7228766172206E3D742E6C617374456C656D656E744368696C643B6E26';
wwv_flow_imp.g_varchar2_table(55) := '26286E3D3D3D46742E67686F73747C7C226E6F6E65223D3D3D53286E2C22646973706C617922297C7C6526262176286E2C6529293B296E3D6E2E70726576696F7573456C656D656E745369626C696E673B72657475726E206E7C7C6E756C6C7D66756E63';
wwv_flow_imp.g_varchar2_table(56) := '74696F6E204E28742C65297B766172206E3D303B69662821747C7C21742E706172656E744E6F64652972657475726E2D313B666F72283B743D742E70726576696F7573456C656D656E745369626C696E673B292254454D504C415445223D3D3D742E6E6F';
wwv_flow_imp.g_varchar2_table(57) := '64654E616D652E746F55707065724361736528297C7C743D3D3D46742E636C6F6E657C7C652626217628742C65297C7C6E2B2B3B72657475726E206E7D66756E6374696F6E20492874297B76617220653D302C6E3D302C6F3D5428293B6966287429646F';
wwv_flow_imp.g_varchar2_table(58) := '7B76617220693D28723D5F287429292E612C723D722E647D7768696C6528652B3D742E7363726F6C6C4C6566742A692C6E2B3D742E7363726F6C6C546F702A722C74213D3D6F262628743D742E706172656E744E6F646529293B72657475726E5B652C6E';
wwv_flow_imp.g_varchar2_table(59) := '5D7D66756E6374696F6E205028742C65297B69662821747C7C21742E676574426F756E64696E67436C69656E74526563742972657475726E205428293B766172206E3D742C6F3D21313B646F7B6966286E2E636C69656E7457696474683C6E2E7363726F';
wwv_flow_imp.g_varchar2_table(60) := '6C6C57696474687C7C6E2E636C69656E744865696768743C6E2E7363726F6C6C486569676874297B76617220693D53286E293B6966286E2E636C69656E7457696474683C6E2E7363726F6C6C5769647468262628226175746F223D3D692E6F766572666C';
wwv_flow_imp.g_varchar2_table(61) := '6F77587C7C227363726F6C6C223D3D692E6F766572666C6F7758297C7C6E2E636C69656E744865696768743C6E2E7363726F6C6C486569676874262628226175746F223D3D692E6F766572666C6F77597C7C227363726F6C6C223D3D692E6F766572666C';
wwv_flow_imp.g_varchar2_table(62) := '6F775929297B696628216E2E676574426F756E64696E67436C69656E74526563747C7C6E3D3D3D646F63756D656E742E626F64792972657475726E205428293B6966286F7C7C652972657475726E206E3B6F3D21307D7D7D7768696C65286E3D6E2E7061';
wwv_flow_imp.g_varchar2_table(63) := '72656E744E6F6465293B72657475726E205428297D66756E6374696F6E206B28742C65297B72657475726E204D6174682E726F756E6428742E746F70293D3D3D4D6174682E726F756E6428652E746F702926264D6174682E726F756E6428742E6C656674';
wwv_flow_imp.g_varchar2_table(64) := '293D3D3D4D6174682E726F756E6428652E6C6566742926264D6174682E726F756E6428742E686569676874293D3D3D4D6174682E726F756E6428652E6865696768742926264D6174682E726F756E6428742E7769647468293D3D3D4D6174682E726F756E';
wwv_flow_imp.g_varchar2_table(65) := '6428652E7769647468297D66756E6374696F6E205228742C65297B72657475726E2066756E6374696F6E28297B766172206E3B777C7C28313D3D3D286E3D617267756D656E7473292E6C656E6774683F742E63616C6C28746869732C6E5B305D293A742E';
wwv_flow_imp.g_varchar2_table(66) := '6170706C7928746869732C6E292C773D73657454696D656F7574282866756E6374696F6E28297B773D766F696420307D292C6529297D7D66756E6374696F6E205828742C652C6E297B742E7363726F6C6C4C6566742B3D652C742E7363726F6C6C546F70';
wwv_flow_imp.g_varchar2_table(67) := '2B3D6E7D66756E6374696F6E20592874297B76617220653D77696E646F772E506F6C796D65722C6E3D77696E646F772E6A51756572797C7C77696E646F772E5A6570746F3B72657475726E20652626652E646F6D3F652E646F6D2874292E636C6F6E654E';
wwv_flow_imp.g_varchar2_table(68) := '6F6465282130293A6E3F6E2874292E636C6F6E65282130295B305D3A742E636C6F6E654E6F6465282130297D66756E6374696F6E204228742C65297B5328742C22706F736974696F6E222C226162736F6C75746522292C5328742C22746F70222C652E74';
wwv_flow_imp.g_varchar2_table(69) := '6F70292C5328742C226C656674222C652E6C656674292C5328742C227769647468222C652E7769647468292C5328742C22686569676874222C652E686569676874297D66756E6374696F6E20462874297B5328742C22706F736974696F6E222C2222292C';
wwv_flow_imp.g_varchar2_table(70) := '5328742C22746F70222C2222292C5328742C226C656674222C2222292C5328742C227769647468222C2222292C5328742C22686569676874222C2222297D66756E6374696F6E206A28742C652C6E297B766172206F3D7B7D3B72657475726E2041727261';
wwv_flow_imp.g_varchar2_table(71) := '792E66726F6D28742E6368696C6472656E292E666F7245616368282866756E6374696F6E2869297B76617220723B7928692C652E647261676761626C652C742C213129262621692E616E696D61746564262669213D3D6E262628723D782869292C6F2E6C';
wwv_flow_imp.g_varchar2_table(72) := '6566743D4D6174682E6D696E286E756C6C213D3D28693D6F2E6C656674292626766F69642030213D3D693F693A312F302C722E6C656674292C6F2E746F703D4D6174682E6D696E286E756C6C213D3D28693D6F2E746F70292626766F69642030213D3D69';
wwv_flow_imp.g_varchar2_table(73) := '3F693A312F302C722E746F70292C6F2E72696768743D4D6174682E6D6178286E756C6C213D3D28693D6F2E7269676874292626766F69642030213D3D693F693A2D312F302C722E7269676874292C6F2E626F74746F6D3D4D6174682E6D6178286E756C6C';
wwv_flow_imp.g_varchar2_table(74) := '213D3D28693D6F2E626F74746F6D292626766F69642030213D3D693F693A2D312F302C722E626F74746F6D29297D29292C6F2E77696474683D6F2E72696768742D6F2E6C6566742C6F2E6865696768743D6F2E626F74746F6D2D6F2E746F702C6F2E783D';
wwv_flow_imp.g_varchar2_table(75) := '6F2E6C6566742C6F2E793D6F2E746F702C6F7D76617220483D22536F727461626C65222B286E65772044617465292E67657454696D6528293B766172204C3D5B5D2C4B3D7B696E697469616C697A65427944656661756C743A21307D2C573D7B6D6F756E';
wwv_flow_imp.g_varchar2_table(76) := '743A66756E6374696F6E2874297B666F7228766172206520696E204B29214B2E6861734F776E50726F70657274792865297C7C6520696E20747C7C28745B655D3D4B5B655D293B4C2E666F7245616368282866756E6374696F6E2865297B696628652E70';
wwv_flow_imp.g_varchar2_table(77) := '6C7567696E4E616D653D3D3D742E706C7567696E4E616D65297468726F7722536F727461626C653A2043616E6E6F74206D6F756E7420706C7567696E20222E636F6E63617428742E706C7567696E4E616D652C22206D6F7265207468616E206F6E636522';
wwv_flow_imp.g_varchar2_table(78) := '297D29292C4C2E707573682874297D2C706C7567696E4576656E743A66756E6374696F6E28742C652C6E297B766172206F3D746869733B746869732E6576656E7443616E63656C65643D21312C6E2E63616E63656C3D66756E6374696F6E28297B6F2E65';
wwv_flow_imp.g_varchar2_table(79) := '76656E7443616E63656C65643D21307D3B76617220723D742B22476C6F62616C223B4C2E666F7245616368282866756E6374696F6E286F297B655B6F2E706C7567696E4E616D655D262628655B6F2E706C7567696E4E616D655D5B725D2626655B6F2E70';
wwv_flow_imp.g_varchar2_table(80) := '6C7567696E4E616D655D5B725D2869287B736F727461626C653A657D2C6E29292C652E6F7074696F6E735B6F2E706C7567696E4E616D655D2626655B6F2E706C7567696E4E616D655D5B745D2626655B6F2E706C7567696E4E616D655D5B745D2869287B';
wwv_flow_imp.g_varchar2_table(81) := '736F727461626C653A657D2C6E2929297D29297D2C696E697469616C697A65506C7567696E733A66756E6374696F6E28742C652C6F2C69297B666F7228766172207220696E204C2E666F7245616368282866756E6374696F6E2869297B76617220723D69';
wwv_flow_imp.g_varchar2_table(82) := '2E706C7567696E4E616D653B28742E6F7074696F6E735B725D7C7C692E696E697469616C697A65427944656661756C742926262828693D6E6577206928742C652C742E6F7074696F6E7329292E736F727461626C653D742C692E6F7074696F6E733D742E';
wwv_flow_imp.g_varchar2_table(83) := '6F7074696F6E732C745B725D3D692C6E286F2C692E64656661756C747329297D29292C742E6F7074696F6E73297B76617220613B742E6F7074696F6E732E6861734F776E50726F70657274792872292626766F69642030213D3D28613D746869732E6D6F';
wwv_flow_imp.g_varchar2_table(84) := '646966794F7074696F6E28742C722C742E6F7074696F6E735B725D2929262628742E6F7074696F6E735B725D3D61297D7D2C6765744576656E7450726F706572746965733A66756E6374696F6E28742C65297B766172206F3D7B7D3B72657475726E204C';
wwv_flow_imp.g_varchar2_table(85) := '2E666F7245616368282866756E6374696F6E2869297B2266756E6374696F6E223D3D747970656F6620692E6576656E7450726F7065727469657326266E286F2C692E6576656E7450726F706572746965732E63616C6C28655B692E706C7567696E4E616D';
wwv_flow_imp.g_varchar2_table(86) := '655D2C7429297D29292C6F7D2C6D6F646966794F7074696F6E3A66756E6374696F6E28742C652C6E297B766172206F3B72657475726E204C2E666F7245616368282866756E6374696F6E2869297B745B692E706C7567696E4E616D655D2626692E6F7074';
wwv_flow_imp.g_varchar2_table(87) := '696F6E4C697374656E65727326262266756E6374696F6E223D3D747970656F6620692E6F7074696F6E4C697374656E6572735B655D2626286F3D692E6F7074696F6E4C697374656E6572735B655D2E63616C6C28745B692E706C7567696E4E616D655D2C';
wwv_flow_imp.g_varchar2_table(88) := '6E29297D29292C6F7D7D3B66756E6374696F6E207A2874297B76617220653D742E736F727461626C652C6E3D742E726F6F74456C2C6F3D742E6E616D652C723D742E746172676574456C2C613D742E636C6F6E65456C2C6C3D742E746F456C2C753D742E';
wwv_flow_imp.g_varchar2_table(89) := '66726F6D456C2C643D742E6F6C64496E6465782C683D742E6E6577496E6465782C703D742E6F6C64447261676761626C65496E6465782C663D742E6E6577447261676761626C65496E6465782C673D742E6F726967696E616C4576656E742C6D3D742E70';
wwv_flow_imp.g_varchar2_table(90) := '7574536F727461626C652C763D742E65787472614576656E7450726F706572746965733B696628653D657C7C6E26266E5B485D297B76617220622C793D652E6F7074696F6E733B743D226F6E222B6F2E6368617241742830292E746F5570706572436173';
wwv_flow_imp.g_varchar2_table(91) := '6528292B6F2E7375627374722831293B2177696E646F772E437573746F6D4576656E747C7C737C7C633F28623D646F63756D656E742E6372656174654576656E7428224576656E742229292E696E69744576656E74286F2C21302C2130293A623D6E6577';
wwv_flow_imp.g_varchar2_table(92) := '20437573746F6D4576656E74286F2C7B627562626C65733A21302C63616E63656C61626C653A21307D292C622E746F3D6C7C7C6E2C622E66726F6D3D757C7C6E2C622E6974656D3D727C7C6E2C622E636C6F6E653D612C622E6F6C64496E6465783D642C';
wwv_flow_imp.g_varchar2_table(93) := '622E6E6577496E6465783D682C622E6F6C64447261676761626C65496E6465783D702C622E6E6577447261676761626C65496E6465783D662C622E6F726967696E616C4576656E743D672C622E70756C6C4D6F64653D6D3F6D2E6C6173745075744D6F64';
wwv_flow_imp.g_varchar2_table(94) := '653A766F696420303B76617220772C443D692869287B7D2C76292C572E6765744576656E7450726F70657274696573286F2C6529293B666F72287720696E204429625B775D3D445B775D3B6E26266E2E64697370617463684576656E742862292C795B74';
wwv_flow_imp.g_varchar2_table(95) := '5D2626795B745D2E63616C6C28652C62297D7D66756E6374696F6E204728742C65297B766172206E3D286F3D323C617267756D656E74732E6C656E6774682626766F69642030213D3D617267756D656E74735B325D3F617267756D656E74735B325D3A7B';
wwv_flow_imp.g_varchar2_table(96) := '7D292E6576742C6F3D66756E6374696F6E28742C65297B6966286E756C6C3D3D742972657475726E7B7D3B766172206E2C6F3D66756E6374696F6E28742C65297B6966286E756C6C3D3D742972657475726E7B7D3B766172206E2C6F3D7B7D3B666F7228';
wwv_flow_imp.g_varchar2_table(97) := '6E20696E2074296966287B7D2E6861734F776E50726F70657274792E63616C6C28742C6E29297B6966282D31213D3D652E696E6465784F66286E2929636F6E74696E75653B6F5B6E5D3D745B6E5D7D72657475726E206F7D28742C65293B6966284F626A';
wwv_flow_imp.g_varchar2_table(98) := '6563742E6765744F776E50726F706572747953796D626F6C7329666F722876617220693D4F626A6563742E6765744F776E50726F706572747953796D626F6C732874292C723D303B723C692E6C656E6774683B722B2B296E3D695B725D2C2D313D3D3D65';
wwv_flow_imp.g_varchar2_table(99) := '2E696E6465784F66286E2926267B7D2E70726F70657274794973456E756D657261626C652E63616C6C28742C6E292626286F5B6E5D3D745B6E5D293B72657475726E206F7D286F2C55293B572E706C7567696E4576656E742E62696E642846742928742C';
wwv_flow_imp.g_varchar2_table(100) := '652C69287B64726167456C3A562C706172656E74456C3A5A2C67686F7374456C3A242C726F6F74456C3A512C6E657874456C3A4A2C6C617374446F776E456C3A74742C636C6F6E65456C3A65742C636C6F6E6548696464656E3A6E742C64726167537461';
wwv_flow_imp.g_varchar2_table(101) := '727465643A67742C707574536F727461626C653A73742C616374697665536F727461626C653A46742E6163746976652C6F726967696E616C4576656E743A6E2C6F6C64496E6465783A6F742C6F6C64447261676761626C65496E6465783A72742C6E6577';
wwv_flow_imp.g_varchar2_table(102) := '496E6465783A69742C6E6577447261676761626C65496E6465783A61742C6869646547686F7374466F725461726765743A52742C756E6869646547686F7374466F725461726765743A58742C636C6F6E654E6F7748696464656E3A66756E6374696F6E28';
wwv_flow_imp.g_varchar2_table(103) := '297B6E743D21307D2C636C6F6E654E6F7753686F776E3A66756E6374696F6E28297B6E743D21317D2C6469737061746368536F727461626C654576656E743A66756E6374696F6E2874297B71287B736F727461626C653A652C6E616D653A742C6F726967';
wwv_flow_imp.g_varchar2_table(104) := '696E616C4576656E743A6E7D297D7D2C6F29297D76617220553D5B22657674225D3B66756E6374696F6E20712874297B7A2869287B707574536F727461626C653A73742C636C6F6E65456C3A65742C746172676574456C3A562C726F6F74456C3A512C6F';
wwv_flow_imp.g_varchar2_table(105) := '6C64496E6465783A6F742C6F6C64447261676761626C65496E6465783A72742C6E6577496E6465783A69742C6E6577447261676761626C65496E6465783A61747D2C7429297D76617220562C5A2C242C512C4A2C74742C65742C6E742C6F742C69742C72';
wwv_flow_imp.g_varchar2_table(106) := '742C61742C6C742C73742C63742C75742C64742C68742C70742C66742C67742C6D742C76742C62742C79742C77743D21312C44743D21312C45743D5B5D2C53743D21312C5F743D21312C43743D5B5D2C54743D21312C78743D5B5D2C4F743D22756E6465';
wwv_flow_imp.g_varchar2_table(107) := '66696E656422213D747970656F6620646F63756D656E742C4D743D682C41743D637C7C733F22637373466C6F6174223A22666C6F6174222C4E743D4F742626217026262168262622647261676761626C6522696E20646F63756D656E742E637265617465';
wwv_flow_imp.g_varchar2_table(108) := '456C656D656E74282264697622292C49743D66756E6374696F6E28297B6966284F74297B696628732972657475726E21313B76617220743D646F63756D656E742E637265617465456C656D656E7428227822293B72657475726E20742E7374796C652E63';
wwv_flow_imp.g_varchar2_table(109) := '7373546578743D22706F696E7465722D6576656E74733A6175746F222C226175746F223D3D3D742E7374796C652E706F696E7465724576656E74737D7D28292C50743D66756E6374696F6E28742C65297B766172206E3D532874292C6F3D706172736549';
wwv_flow_imp.g_varchar2_table(110) := '6E74286E2E7769647468292D7061727365496E74286E2E70616464696E674C656674292D7061727365496E74286E2E70616464696E675269676874292D7061727365496E74286E2E626F726465724C6566745769647468292D7061727365496E74286E2E';
wwv_flow_imp.g_varchar2_table(111) := '626F7264657252696768745769647468292C693D4D28742C302C65292C723D4D28742C312C65292C613D692626532869292C6C3D722626532872292C733D6126267061727365496E7428612E6D617267696E4C656674292B7061727365496E7428612E6D';
wwv_flow_imp.g_varchar2_table(112) := '617267696E5269676874292B782869292E77696474683B743D6C26267061727365496E74286C2E6D617267696E4C656674292B7061727365496E74286C2E6D617267696E5269676874292B782872292E77696474683B72657475726E22666C6578223D3D';
wwv_flow_imp.g_varchar2_table(113) := '3D6E2E646973706C61793F22636F6C756D6E223D3D3D6E2E666C6578446972656374696F6E7C7C22636F6C756D6E2D72657665727365223D3D3D6E2E666C6578446972656374696F6E3F22766572746963616C223A22686F72697A6F6E74616C223A2267';
wwv_flow_imp.g_varchar2_table(114) := '726964223D3D3D6E2E646973706C61793F6E2E6772696454656D706C617465436F6C756D6E732E73706C697428222022292E6C656E6774683C3D313F22766572746963616C223A22686F72697A6F6E74616C223A692626612E666C6F61742626226E6F6E';
wwv_flow_imp.g_varchar2_table(115) := '6522213D3D612E666C6F61743F28653D226C656674223D3D3D612E666C6F61743F226C656674223A227269676874222C21727C7C22626F746822213D3D6C2E636C65617226266C2E636C656172213D3D653F22686F72697A6F6E74616C223A2276657274';
wwv_flow_imp.g_varchar2_table(116) := '6963616C22293A6926262822626C6F636B223D3D3D612E646973706C61797C7C22666C6578223D3D3D612E646973706C61797C7C227461626C65223D3D3D612E646973706C61797C7C2267726964223D3D3D612E646973706C61797C7C6F3C3D73262622';
wwv_flow_imp.g_varchar2_table(117) := '6E6F6E65223D3D3D6E5B41745D7C7C722626226E6F6E65223D3D3D6E5B41745D26266F3C732B74293F22766572746963616C223A22686F72697A6F6E74616C227D2C6B743D66756E6374696F6E2874297B66756E6374696F6E206528742C6E297B726574';
wwv_flow_imp.g_varchar2_table(118) := '75726E2066756E6374696F6E286F2C692C722C61297B766172206C3D6F2E6F7074696F6E732E67726F75702E6E616D652626692E6F7074696F6E732E67726F75702E6E616D6526266F2E6F7074696F6E732E67726F75702E6E616D653D3D3D692E6F7074';
wwv_flow_imp.g_varchar2_table(119) := '696F6E732E67726F75702E6E616D653B72657475726E21286E756C6C213D747C7C216E2626216C297C7C6E756C6C213D7426262131213D3D742626286E262622636C6F6E65223D3D3D743F743A2266756E6374696F6E223D3D747970656F6620743F6528';
wwv_flow_imp.g_varchar2_table(120) := '74286F2C692C722C61292C6E29286F2C692C722C61293A28693D286E3F6F3A69292E6F7074696F6E732E67726F75702E6E616D652C21303D3D3D747C7C22737472696E67223D3D747970656F6620742626743D3D3D697C7C742E6A6F696E26262D313C74';
wwv_flow_imp.g_varchar2_table(121) := '2E696E6465784F6628692929297D7D766172206E3D7B7D2C6F3D742E67726F75703B6F2626226F626A656374223D3D61286F297C7C286F3D7B6E616D653A6F7D292C6E2E6E616D653D6F2E6E616D652C6E2E636865636B50756C6C3D65286F2E70756C6C';
wwv_flow_imp.g_varchar2_table(122) := '2C2130292C6E2E636865636B5075743D65286F2E707574292C6E2E726576657274436C6F6E653D6F2E726576657274436C6F6E652C742E67726F75703D6E7D2C52743D66756E6374696F6E28297B21497426262426265328242C22646973706C6179222C';
wwv_flow_imp.g_varchar2_table(123) := '226E6F6E6522297D2C58743D66756E6374696F6E28297B21497426262426265328242C22646973706C6179222C2222297D3B66756E6374696F6E2059742874297B69662856297B743D742E746F75636865733F742E746F75636865735B305D3A743B7661';
wwv_flow_imp.g_varchar2_table(124) := '7220653D28693D742E636C69656E74582C723D742E636C69656E74592C45742E736F6D65282866756E6374696F6E2874297B696628286F3D745B485D2E6F7074696F6E732E656D707479496E736572745468726573686F6C642926262141287429297B76';
wwv_flow_imp.g_varchar2_table(125) := '617220653D782874292C6E3D693E3D652E6C6566742D6F2626693C3D652E72696768742B6F2C6F3D723E3D652E746F702D6F2626723C3D652E626F74746F6D2B6F3B72657475726E206E26266F3F613D743A766F696420307D7D29292C61293B69662865';
wwv_flow_imp.g_varchar2_table(126) := '297B766172206E2C6F3D7B7D3B666F72286E20696E207429742E6861734F776E50726F7065727479286E292626286F5B6E5D3D745B6E5D293B6F2E7461726765743D6F2E726F6F74456C3D652C6F2E70726576656E7444656661756C743D766F69642030';
wwv_flow_imp.g_varchar2_table(127) := '2C6F2E73746F7050726F7061676174696F6E3D766F696420302C655B485D2E5F6F6E447261674F766572286F297D7D76617220692C722C617D66756E6374696F6E2042742874297B562626562E706172656E744E6F64655B485D2E5F69734F7574736964';
wwv_flow_imp.g_varchar2_table(128) := '6554686973456C28742E746172676574297D66756E6374696F6E20467428742C65297B69662821747C7C21742E6E6F6465547970657C7C31213D3D742E6E6F646554797065297468726F7722536F727461626C653A2060656C60206D7573742062652061';
wwv_flow_imp.g_varchar2_table(129) := '6E2048544D4C456C656D656E742C206E6F7420222E636F6E636174287B7D2E746F537472696E672E63616C6C287429293B746869732E656C3D742C746869732E6F7074696F6E733D653D6E287B7D2C65292C745B485D3D746869733B766172206F2C722C';
wwv_flow_imp.g_varchar2_table(130) := '613D7B67726F75703A6E756C6C2C736F72743A21302C64697361626C65643A21312C73746F72653A6E756C6C2C68616E646C653A6E756C6C2C647261676761626C653A2F5E5B756F5D6C242F692E7465737428742E6E6F64654E616D65293F223E6C6922';
wwv_flow_imp.g_varchar2_table(131) := '3A223E2A222C737761705468726573686F6C643A312C696E76657274537761703A21312C696E766572746564537761705468726573686F6C643A6E756C6C2C72656D6F7665436C6F6E654F6E486964653A21302C646972656374696F6E3A66756E637469';
wwv_flow_imp.g_varchar2_table(132) := '6F6E28297B72657475726E20507428742C746869732E6F7074696F6E73297D2C67686F7374436C6173733A22736F727461626C652D67686F7374222C63686F73656E436C6173733A22736F727461626C652D63686F73656E222C64726167436C6173733A';
wwv_flow_imp.g_varchar2_table(133) := '22736F727461626C652D64726167222C69676E6F72653A22612C20696D67222C66696C7465723A6E756C6C2C70726576656E744F6E46696C7465723A21302C616E696D6174696F6E3A302C656173696E673A6E756C6C2C736574446174613A66756E6374';
wwv_flow_imp.g_varchar2_table(134) := '696F6E28742C65297B742E73657444617461282254657874222C652E74657874436F6E74656E74297D2C64726F70427562626C653A21312C647261676F766572427562626C653A21312C646174614964417474723A22646174612D6964222C64656C6179';
wwv_flow_imp.g_varchar2_table(135) := '3A302C64656C61794F6E546F7563684F6E6C793A21312C746F75636853746172745468726573686F6C643A284E756D6265722E7061727365496E743F4E756D6265723A77696E646F77292E7061727365496E742877696E646F772E646576696365506978';
wwv_flow_imp.g_varchar2_table(136) := '656C526174696F2C3130297C7C312C666F72636546616C6C6261636B3A21312C66616C6C6261636B436C6173733A22736F727461626C652D66616C6C6261636B222C66616C6C6261636B4F6E426F64793A21312C66616C6C6261636B546F6C6572616E63';
wwv_flow_imp.g_varchar2_table(137) := '653A302C66616C6C6261636B4F66667365743A7B783A302C793A307D2C737570706F7274506F696E7465723A2131213D3D46742E737570706F7274506F696E746572262622506F696E7465724576656E7422696E2077696E646F7726262821647C7C6829';
wwv_flow_imp.g_varchar2_table(138) := '2C656D707479496E736572745468726573686F6C643A357D3B666F72286F20696E20572E696E697469616C697A65506C7567696E7328746869732C742C61292C61296F20696E20657C7C28655B6F5D3D615B6F5D293B666F72287220696E206B74286529';
wwv_flow_imp.g_varchar2_table(139) := '2C7468697329225F223D3D3D722E63686172417428302926262266756E6374696F6E223D3D747970656F6620746869735B725D262628746869735B725D3D746869735B725D2E62696E64287468697329293B746869732E6E617469766544726167676162';
wwv_flow_imp.g_varchar2_table(140) := '6C653D21652E666F72636546616C6C6261636B26264E742C746869732E6E6174697665447261676761626C65262628746869732E6F7074696F6E732E746F75636853746172745468726573686F6C643D31292C652E737570706F7274506F696E7465723F';
wwv_flow_imp.g_varchar2_table(141) := '6728742C22706F696E746572646F776E222C746869732E5F6F6E5461705374617274293A286728742C226D6F757365646F776E222C746869732E5F6F6E5461705374617274292C6728742C22746F7563687374617274222C746869732E5F6F6E54617053';
wwv_flow_imp.g_varchar2_table(142) := '7461727429292C746869732E6E6174697665447261676761626C652626286728742C22647261676F766572222C74686973292C6728742C2264726167656E746572222C7468697329292C45742E7075736828746869732E656C292C652E73746F72652626';
wwv_flow_imp.g_varchar2_table(143) := '652E73746F72652E6765742626746869732E736F727428652E73746F72652E6765742874686973297C7C5B5D292C6E28746869732C66756E6374696F6E28297B76617220742C653D5B5D3B72657475726E7B63617074757265416E696D6174696F6E5374';
wwv_flow_imp.g_varchar2_table(144) := '6174653A66756E6374696F6E28297B653D5B5D2C746869732E6F7074696F6E732E616E696D6174696F6E26265B5D2E736C6963652E63616C6C28746869732E656C2E6368696C6472656E292E666F7245616368282866756E6374696F6E2874297B766172';
wwv_flow_imp.g_varchar2_table(145) := '206E2C6F3B226E6F6E6522213D3D5328742C22646973706C61792229262674213D3D46742E67686F7374262628652E70757368287B7461726765743A742C726563743A782874297D292C6E3D69287B7D2C655B652E6C656E6774682D315D2E7265637429';
wwv_flow_imp.g_varchar2_table(146) := '2C21742E74686973416E696D6174696F6E4475726174696F6E7C7C286F3D5F28742C213029292626286E2E746F702D3D6F2E662C6E2E6C6566742D3D6F2E65292C742E66726F6D526563743D6E297D29297D2C616464416E696D6174696F6E5374617465';
wwv_flow_imp.g_varchar2_table(147) := '3A66756E6374696F6E2874297B652E707573682874297D2C72656D6F7665416E696D6174696F6E53746174653A66756E6374696F6E2874297B652E73706C6963652866756E6374696F6E28742C65297B666F7228766172206E20696E207429696628742E';
wwv_flow_imp.g_varchar2_table(148) := '6861734F776E50726F7065727479286E2929666F7228766172206F20696E206529696628652E6861734F776E50726F7065727479286F292626655B6F5D3D3D3D745B6E5D5B6F5D2972657475726E204E756D626572286E293B72657475726E2D317D2865';
wwv_flow_imp.g_varchar2_table(149) := '2C7B7461726765743A747D292C31297D2C616E696D617465416C6C3A66756E6374696F6E286E297B766172206F3D746869733B69662821746869732E6F7074696F6E732E616E696D6174696F6E2972657475726E20636C65617254696D656F7574287429';
wwv_flow_imp.g_varchar2_table(150) := '2C766F6964282266756E6374696F6E223D3D747970656F66206E26266E2829293B76617220693D21312C723D303B652E666F7245616368282866756E6374696F6E2874297B76617220653D302C6E3D742E7461726765742C613D6E2E66726F6D52656374';
wwv_flow_imp.g_varchar2_table(151) := '2C6C3D78286E292C733D6E2E7072657646726F6D526563742C633D6E2E70726576546F526563742C753D742E726563742C643D5F286E2C2130293B642626286C2E746F702D3D642E662C6C2E6C6566742D3D642E65292C6E2E746F526563743D6C2C6E2E';
wwv_flow_imp.g_varchar2_table(152) := '74686973416E696D6174696F6E4475726174696F6E26266B28732C6C292626216B28612C6C29262628752E746F702D6C2E746F70292F28752E6C6566742D6C2E6C656674293D3D28612E746F702D6C2E746F70292F28612E6C6566742D6C2E6C65667429';
wwv_flow_imp.g_varchar2_table(153) := '262628743D752C643D732C733D632C633D6F2E6F7074696F6E732C653D4D6174682E73717274284D6174682E706F7728642E746F702D742E746F702C32292B4D6174682E706F7728642E6C6566742D742E6C6566742C3229292F4D6174682E7371727428';
wwv_flow_imp.g_varchar2_table(154) := '4D6174682E706F7728642E746F702D732E746F702C32292B4D6174682E706F7728642E6C6566742D732E6C6566742C3229292A632E616E696D6174696F6E292C6B286C2C61297C7C286E2E7072657646726F6D526563743D612C6E2E70726576546F5265';
wwv_flow_imp.g_varchar2_table(155) := '63743D6C2C653D657C7C6F2E6F7074696F6E732E616E696D6174696F6E2C6F2E616E696D617465286E2C752C6C2C6529292C65262628693D21302C723D4D6174682E6D617828722C65292C636C65617254696D656F7574286E2E616E696D6174696F6E52';
wwv_flow_imp.g_varchar2_table(156) := '6573657454696D6572292C6E2E616E696D6174696F6E526573657454696D65723D73657454696D656F7574282866756E6374696F6E28297B6E2E616E696D6174696F6E54696D653D302C6E2E7072657646726F6D526563743D6E756C6C2C6E2E66726F6D';
wwv_flow_imp.g_varchar2_table(157) := '526563743D6E756C6C2C6E2E70726576546F526563743D6E756C6C2C6E2E74686973416E696D6174696F6E4475726174696F6E3D6E756C6C7D292C65292C6E2E74686973416E696D6174696F6E4475726174696F6E3D65297D29292C636C65617254696D';
wwv_flow_imp.g_varchar2_table(158) := '656F75742874292C693F743D73657454696D656F7574282866756E6374696F6E28297B2266756E6374696F6E223D3D747970656F66206E26266E28297D292C72293A2266756E6374696F6E223D3D747970656F66206E26266E28292C653D5B5D7D2C616E';
wwv_flow_imp.g_varchar2_table(159) := '696D6174653A66756E6374696F6E28742C652C6E2C6F297B76617220692C723B6F2626285328742C227472616E736974696F6E222C2222292C5328742C227472616E73666F726D222C2222292C693D28723D5F28746869732E656C29292626722E612C72';
wwv_flow_imp.g_varchar2_table(160) := '3D722626722E642C693D28652E6C6566742D6E2E6C656674292F28697C7C31292C723D28652E746F702D6E2E746F70292F28727C7C31292C742E616E696D6174696E67583D2121692C742E616E696D6174696E67593D2121722C5328742C227472616E73';
wwv_flow_imp.g_varchar2_table(161) := '666F726D222C227472616E736C617465336428222B692B2270782C222B722B2270782C302922292C746869732E666F7252657061696E7444756D6D793D742E6F666673657457696474682C5328742C227472616E736974696F6E222C227472616E73666F';
wwv_flow_imp.g_varchar2_table(162) := '726D20222B6F2B226D73222B28746869732E6F7074696F6E732E656173696E673F2220222B746869732E6F7074696F6E732E656173696E673A222229292C5328742C227472616E73666F726D222C227472616E736C617465336428302C302C302922292C';
wwv_flow_imp.g_varchar2_table(163) := '226E756D626572223D3D747970656F6620742E616E696D617465642626636C65617254696D656F757428742E616E696D61746564292C742E616E696D617465643D73657454696D656F7574282866756E6374696F6E28297B5328742C227472616E736974';
wwv_flow_imp.g_varchar2_table(164) := '696F6E222C2222292C5328742C227472616E73666F726D222C2222292C742E616E696D617465643D21312C742E616E696D6174696E67583D21312C742E616E696D6174696E67593D21317D292C6F29297D7D7D2829297D66756E6374696F6E206A742874';
wwv_flow_imp.g_varchar2_table(165) := '2C652C6E2C6F2C692C722C612C6C297B76617220752C642C683D745B485D2C703D682E6F7074696F6E732E6F6E4D6F76653B72657475726E2177696E646F772E437573746F6D4576656E747C7C737C7C633F28753D646F63756D656E742E637265617465';
wwv_flow_imp.g_varchar2_table(166) := '4576656E7428224576656E742229292E696E69744576656E7428226D6F7665222C21302C2130293A753D6E657720437573746F6D4576656E7428226D6F7665222C7B627562626C65733A21302C63616E63656C61626C653A21307D292C752E746F3D652C';
wwv_flow_imp.g_varchar2_table(167) := '752E66726F6D3D742C752E647261676765643D6E2C752E64726167676564526563743D6F2C752E72656C617465643D697C7C652C752E72656C61746564526563743D727C7C782865292C752E77696C6C496E7365727441667465723D6C2C752E6F726967';
wwv_flow_imp.g_varchar2_table(168) := '696E616C4576656E743D612C742E64697370617463684576656E742875292C703F702E63616C6C28682C752C61293A647D66756E6374696F6E2048742874297B742E647261676761626C653D21317D66756E6374696F6E204C7428297B54743D21317D66';
wwv_flow_imp.g_varchar2_table(169) := '756E6374696F6E204B742874297B72657475726E2073657454696D656F757428742C30297D66756E6374696F6E2057742874297B72657475726E20636C65617254696D656F75742874297D4F74262621702626646F63756D656E742E6164644576656E74';
wwv_flow_imp.g_varchar2_table(170) := '4C697374656E65722822636C69636B222C2866756E6374696F6E2874297B69662844742972657475726E20742E70726576656E7444656661756C7428292C742E73746F7050726F7061676174696F6E2626742E73746F7050726F7061676174696F6E2829';
wwv_flow_imp.g_varchar2_table(171) := '2C742E73746F70496D6D65646961746550726F7061676174696F6E2626742E73746F70496D6D65646961746550726F7061676174696F6E28292C44743D21317D292C2130292C46742E70726F746F747970653D7B636F6E7374727563746F723A46742C5F';
wwv_flow_imp.g_varchar2_table(172) := '69734F75747369646554686973456C3A66756E6374696F6E2874297B746869732E656C2E636F6E7461696E732874297C7C743D3D3D746869732E656C7C7C286D743D6E756C6C297D2C5F676574446972656374696F6E3A66756E6374696F6E28742C6529';
wwv_flow_imp.g_varchar2_table(173) := '7B72657475726E2266756E6374696F6E223D3D747970656F6620746869732E6F7074696F6E732E646972656374696F6E3F746869732E6F7074696F6E732E646972656374696F6E2E63616C6C28746869732C742C652C56293A746869732E6F7074696F6E';
wwv_flow_imp.g_varchar2_table(174) := '732E646972656374696F6E7D2C5F6F6E54617053746172743A66756E6374696F6E2874297B696628742E63616E63656C61626C65297B76617220653D746869732C6E3D746869732E656C2C6F3D746869732E6F7074696F6E732C693D6F2E70726576656E';
wwv_flow_imp.g_varchar2_table(175) := '744F6E46696C7465722C723D742E747970652C613D742E746F75636865732626742E746F75636865735B305D7C7C742E706F696E74657254797065262622746F756368223D3D3D742E706F696E746572547970652626742C6C3D28617C7C74292E746172';
wwv_flow_imp.g_varchar2_table(176) := '6765742C733D742E7461726765742E736861646F77526F6F74262628742E706174682626742E706174685B305D7C7C742E636F6D706F736564506174682626742E636F6D706F7365645061746828295B305D297C7C6C2C633D6F2E66696C7465723B6966';
wwv_flow_imp.g_varchar2_table(177) := '2866756E6374696F6E2874297B78742E6C656E6774683D303B666F722876617220653D742E676574456C656D656E747342795461674E616D652822696E70757422292C6E3D652E6C656E6774683B6E2D2D3B297B766172206F3D655B6E5D3B6F2E636865';
wwv_flow_imp.g_varchar2_table(178) := '636B6564262678742E70757368286F297D7D286E292C2156262621282F6D6F757365646F776E7C706F696E746572646F776E2F2E74657374287229262630213D3D742E627574746F6E7C7C6F2E64697361626C656429262621732E6973436F6E74656E74';
wwv_flow_imp.g_varchar2_table(179) := '4564697461626C65262628746869732E6E6174697665447261676761626C657C7C21647C7C216C7C7C2253454C45435422213D3D6C2E7461674E616D652E746F55707065724361736528292926262128286C3D79286C2C6F2E647261676761626C652C6E';
wwv_flow_imp.g_varchar2_table(180) := '2C2131292926266C2E616E696D617465647C7C74743D3D3D6C29297B6966286F743D4E286C292C72743D4E286C2C6F2E647261676761626C65292C2266756E6374696F6E223D3D747970656F662063297B696628632E63616C6C28746869732C742C6C2C';
wwv_flow_imp.g_varchar2_table(181) := '74686973292972657475726E2071287B736F727461626C653A652C726F6F74456C3A732C6E616D653A2266696C746572222C746172676574456C3A6C2C746F456C3A6E2C66726F6D456C3A6E7D292C47282266696C746572222C652C7B6576743A747D29';
wwv_flow_imp.g_varchar2_table(182) := '2C766F696428692626742E70726576656E7444656661756C742829297D656C736520696628633D632626632E73706C697428222C22292E736F6D65282866756E6374696F6E286F297B6966286F3D7928732C6F2E7472696D28292C6E2C21312929726574';
wwv_flow_imp.g_varchar2_table(183) := '75726E2071287B736F727461626C653A652C726F6F74456C3A6F2C6E616D653A2266696C746572222C746172676574456C3A6C2C66726F6D456C3A6E2C746F456C3A6E7D292C47282266696C746572222C652C7B6576743A747D292C21307D2929297265';
wwv_flow_imp.g_varchar2_table(184) := '7475726E20766F696428692626742E70726576656E7444656661756C742829293B6F2E68616E646C652626217928732C6F2E68616E646C652C6E2C2131297C7C746869732E5F7072657061726544726167537461727428742C612C6C297D7D7D2C5F7072';
wwv_flow_imp.g_varchar2_table(185) := '65706172654472616753746172743A66756E6374696F6E28742C652C6E297B766172206F2C693D746869732C723D692E656C2C613D692E6F7074696F6E732C6C3D722E6F776E6572446F63756D656E743B6E2626215626266E2E706172656E744E6F6465';
wwv_flow_imp.g_varchar2_table(186) := '3D3D3D722626286F3D78286E292C513D722C5A3D28563D6E292E706172656E744E6F64652C4A3D562E6E6578745369626C696E672C74743D6E2C6C743D612E67726F75702C63743D7B7461726765743A46742E647261676765643D562C636C69656E7458';
wwv_flow_imp.g_varchar2_table(187) := '3A28657C7C74292E636C69656E74582C636C69656E74593A28657C7C74292E636C69656E74597D2C70743D63742E636C69656E74582D6F2E6C6566742C66743D63742E636C69656E74592D6F2E746F702C746869732E5F6C617374583D28657C7C74292E';
wwv_flow_imp.g_varchar2_table(188) := '636C69656E74582C746869732E5F6C617374593D28657C7C74292E636C69656E74592C562E7374796C655B2277696C6C2D6368616E6765225D3D22616C6C222C6F3D66756E6374696F6E28297B47282264656C6179456E646564222C692C7B6576743A74';
wwv_flow_imp.g_varchar2_table(189) := '7D292C46742E6576656E7443616E63656C65643F692E5F6F6E44726F7028293A28692E5F64697361626C6544656C61796564447261674576656E747328292C21752626692E6E6174697665447261676761626C65262628562E647261676761626C653D21';
wwv_flow_imp.g_varchar2_table(190) := '30292C692E5F7472696767657244726167537461727428742C65292C71287B736F727461626C653A692C6E616D653A2263686F6F7365222C6F726967696E616C4576656E743A747D292C4528562C612E63686F73656E436C6173732C213029297D2C612E';
wwv_flow_imp.g_varchar2_table(191) := '69676E6F72652E73706C697428222C22292E666F7245616368282866756E6374696F6E2874297B4328562C742E7472696D28292C4874297D29292C67286C2C22647261676F766572222C5974292C67286C2C226D6F7573656D6F7665222C5974292C6728';
wwv_flow_imp.g_varchar2_table(192) := '6C2C22746F7563686D6F7665222C5974292C612E737570706F7274506F696E7465723F2867286C2C22706F696E7465727570222C692E5F6F6E44726F70292C746869732E6E6174697665447261676761626C657C7C67286C2C22706F696E74657263616E';
wwv_flow_imp.g_varchar2_table(193) := '63656C222C692E5F6F6E44726F7029293A2867286C2C226D6F7573657570222C692E5F6F6E44726F70292C67286C2C22746F756368656E64222C692E5F6F6E44726F70292C67286C2C22746F75636863616E63656C222C692E5F6F6E44726F7029292C75';
wwv_flow_imp.g_varchar2_table(194) := '2626746869732E6E6174697665447261676761626C65262628746869732E6F7074696F6E732E746F75636853746172745468726573686F6C643D342C562E647261676761626C653D2130292C47282264656C61795374617274222C746869732C7B657674';
wwv_flow_imp.g_varchar2_table(195) := '3A747D292C21612E64656C61797C7C612E64656C61794F6E546F7563684F6E6C79262621657C7C746869732E6E6174697665447261676761626C65262628637C7C73293F6F28293A46742E6576656E7443616E63656C65643F746869732E5F6F6E44726F';
wwv_flow_imp.g_varchar2_table(196) := '7028293A28612E737570706F7274506F696E7465723F2867286C2C22706F696E7465727570222C692E5F64697361626C6544656C6179656444726167292C67286C2C22706F696E74657263616E63656C222C692E5F64697361626C6544656C6179656444';
wwv_flow_imp.g_varchar2_table(197) := '72616729293A2867286C2C226D6F7573657570222C692E5F64697361626C6544656C6179656444726167292C67286C2C22746F756368656E64222C692E5F64697361626C6544656C6179656444726167292C67286C2C22746F75636863616E63656C222C';
wwv_flow_imp.g_varchar2_table(198) := '692E5F64697361626C6544656C617965644472616729292C67286C2C226D6F7573656D6F7665222C692E5F64656C6179656444726167546F7563684D6F766548616E646C6572292C67286C2C22746F7563686D6F7665222C692E5F64656C617965644472';
wwv_flow_imp.g_varchar2_table(199) := '6167546F7563684D6F766548616E646C6572292C612E737570706F7274506F696E746572262667286C2C22706F696E7465726D6F7665222C692E5F64656C6179656444726167546F7563684D6F766548616E646C6572292C692E5F647261675374617274';
wwv_flow_imp.g_varchar2_table(200) := '54696D65723D73657454696D656F7574286F2C612E64656C61792929297D2C5F64656C6179656444726167546F7563684D6F766548616E646C65723A66756E6374696F6E2874297B743D742E746F75636865733F742E746F75636865735B305D3A742C4D';
wwv_flow_imp.g_varchar2_table(201) := '6174682E6D6178284D6174682E61627328742E636C69656E74582D746869732E5F6C61737458292C4D6174682E61627328742E636C69656E74592D746869732E5F6C6173745929293E3D4D6174682E666C6F6F7228746869732E6F7074696F6E732E746F';
wwv_flow_imp.g_varchar2_table(202) := '75636853746172745468726573686F6C642F28746869732E6E6174697665447261676761626C65262677696E646F772E646576696365506978656C526174696F7C7C3129292626746869732E5F64697361626C6544656C617965644472616728297D2C5F';
wwv_flow_imp.g_varchar2_table(203) := '64697361626C6544656C61796564447261673A66756E6374696F6E28297B56262648742856292C636C65617254696D656F757428746869732E5F64726167537461727454696D6572292C746869732E5F64697361626C6544656C61796564447261674576';
wwv_flow_imp.g_varchar2_table(204) := '656E747328297D2C5F64697361626C6544656C61796564447261674576656E74733A66756E6374696F6E28297B76617220743D746869732E656C2E6F776E6572446F63756D656E743B6D28742C226D6F7573657570222C746869732E5F64697361626C65';
wwv_flow_imp.g_varchar2_table(205) := '44656C6179656444726167292C6D28742C22746F756368656E64222C746869732E5F64697361626C6544656C6179656444726167292C6D28742C22746F75636863616E63656C222C746869732E5F64697361626C6544656C6179656444726167292C6D28';
wwv_flow_imp.g_varchar2_table(206) := '742C22706F696E7465727570222C746869732E5F64697361626C6544656C6179656444726167292C6D28742C22706F696E74657263616E63656C222C746869732E5F64697361626C6544656C6179656444726167292C6D28742C226D6F7573656D6F7665';
wwv_flow_imp.g_varchar2_table(207) := '222C746869732E5F64656C6179656444726167546F7563684D6F766548616E646C6572292C6D28742C22746F7563686D6F7665222C746869732E5F64656C6179656444726167546F7563684D6F766548616E646C6572292C6D28742C22706F696E746572';
wwv_flow_imp.g_varchar2_table(208) := '6D6F7665222C746869732E5F64656C6179656444726167546F7563684D6F766548616E646C6572297D2C5F747269676765724472616753746172743A66756E6374696F6E28742C65297B653D657C7C22746F756368223D3D742E706F696E746572547970';
wwv_flow_imp.g_varchar2_table(209) := '652626742C21746869732E6E6174697665447261676761626C657C7C653F746869732E6F7074696F6E732E737570706F7274506F696E7465723F6728646F63756D656E742C22706F696E7465726D6F7665222C746869732E5F6F6E546F7563684D6F7665';
wwv_flow_imp.g_varchar2_table(210) := '293A6728646F63756D656E742C653F22746F7563686D6F7665223A226D6F7573656D6F7665222C746869732E5F6F6E546F7563684D6F7665293A286728562C2264726167656E64222C74686973292C6728512C22647261677374617274222C746869732E';
wwv_flow_imp.g_varchar2_table(211) := '5F6F6E44726167537461727429293B7472797B646F63756D656E742E73656C656374696F6E3F4B74282866756E6374696F6E28297B646F63756D656E742E73656C656374696F6E2E656D70747928297D29293A77696E646F772E67657453656C65637469';
wwv_flow_imp.g_varchar2_table(212) := '6F6E28292E72656D6F7665416C6C52616E67657328297D63617463682874297B7D7D2C5F64726167537461727465643A66756E6374696F6E28742C65297B766172206E3B77743D21312C512626563F284728226472616753746172746564222C74686973';
wwv_flow_imp.g_varchar2_table(213) := '2C7B6576743A657D292C746869732E6E6174697665447261676761626C6526266728646F63756D656E742C22647261676F766572222C4274292C6E3D746869732E6F7074696F6E732C747C7C4528562C6E2E64726167436C6173732C2131292C4528562C';
wwv_flow_imp.g_varchar2_table(214) := '6E2E67686F7374436C6173732C2130292C46742E6163746976653D746869732C742626746869732E5F617070656E6447686F737428292C71287B736F727461626C653A746869732C6E616D653A227374617274222C6F726967696E616C4576656E743A65';
wwv_flow_imp.g_varchar2_table(215) := '7D29293A746869732E5F6E756C6C696E6728297D2C5F656D756C617465447261674F7665723A66756E6374696F6E28297B6966287574297B746869732E5F6C617374583D75742E636C69656E74582C746869732E5F6C617374593D75742E636C69656E74';
wwv_flow_imp.g_varchar2_table(216) := '592C527428293B666F722876617220743D646F63756D656E742E656C656D656E7446726F6D506F696E742875742E636C69656E74582C75742E636C69656E7459292C653D743B742626742E736861646F77526F6F74262628743D742E736861646F77526F';
wwv_flow_imp.g_varchar2_table(217) := '6F742E656C656D656E7446726F6D506F696E742875742E636C69656E74582C75742E636C69656E74592929213D3D653B29653D743B696628562E706172656E744E6F64655B485D2E5F69734F75747369646554686973456C2874292C6529646F7B696628';
wwv_flow_imp.g_varchar2_table(218) := '655B485D2626655B485D2E5F6F6E447261674F766572287B636C69656E74583A75742E636C69656E74582C636C69656E74593A75742E636C69656E74592C7461726765743A742C726F6F74456C3A657D29262621746869732E6F7074696F6E732E647261';
wwv_flow_imp.g_varchar2_table(219) := '676F766572427562626C6529627265616B7D7768696C6528653D6228743D6529293B587428297D7D2C5F6F6E546F7563684D6F76653A66756E6374696F6E2874297B6966286374297B76617220653D286C3D746869732E6F7074696F6E73292E66616C6C';
wwv_flow_imp.g_varchar2_table(220) := '6261636B546F6C6572616E63652C6E3D6C2E66616C6C6261636B4F66667365742C6F3D742E746F75636865733F742E746F75636865735B305D3A742C693D2426265F28242C2130292C723D242626692626692E612C613D242626692626692E642C6C3D4D';
wwv_flow_imp.g_varchar2_table(221) := '7426267974262649287974293B723D286F2E636C69656E74582D63742E636C69656E74582B6E2E78292F28727C7C31292B286C3F6C5B305D2D43745B305D3A30292F28727C7C31292C613D286F2E636C69656E74592D63742E636C69656E74592B6E2E79';
wwv_flow_imp.g_varchar2_table(222) := '292F28617C7C31292B286C3F6C5B315D2D43745B315D3A30292F28617C7C31293B6966282146742E6163746976652626217774297B6966286526264D6174682E6D6178284D6174682E616273286F2E636C69656E74582D746869732E5F6C61737458292C';
wwv_flow_imp.g_varchar2_table(223) := '4D6174682E616273286F2E636C69656E74592D746869732E5F6C6173745929293C652972657475726E3B746869732E5F6F6E44726167537461727428742C2130297D24262628693F28692E652B3D722D2864747C7C30292C692E662B3D612D2868747C7C';
wwv_flow_imp.g_varchar2_table(224) := '3029293A693D7B613A312C623A302C633A302C643A312C653A722C663A617D2C693D226D617472697828222E636F6E63617428692E612C222C22292E636F6E63617428692E622C222C22292E636F6E63617428692E632C222C22292E636F6E6361742869';
wwv_flow_imp.g_varchar2_table(225) := '2E642C222C22292E636F6E63617428692E652C222C22292E636F6E63617428692E662C222922292C5328242C227765626B69745472616E73666F726D222C69292C5328242C226D6F7A5472616E73666F726D222C69292C5328242C226D735472616E7366';
wwv_flow_imp.g_varchar2_table(226) := '6F726D222C69292C5328242C227472616E73666F726D222C69292C64743D722C68743D612C75743D6F292C742E63616E63656C61626C652626742E70726576656E7444656661756C7428297D7D2C5F617070656E6447686F73743A66756E6374696F6E28';
wwv_flow_imp.g_varchar2_table(227) := '297B6966282124297B76617220743D746869732E6F7074696F6E732E66616C6C6261636B4F6E426F64793F646F63756D656E742E626F64793A512C653D7828562C21302C4D742C21302C74292C6E3D746869732E6F7074696F6E733B6966284D74297B66';
wwv_flow_imp.g_varchar2_table(228) := '6F722879743D743B22737461746963223D3D3D532879742C22706F736974696F6E22292626226E6F6E65223D3D3D532879742C227472616E73666F726D222926267974213D3D646F63756D656E743B2979743D79742E706172656E744E6F64653B797421';
wwv_flow_imp.g_varchar2_table(229) := '3D3D646F63756D656E742E626F647926267974213D3D646F63756D656E742E646F63756D656E74456C656D656E743F2879743D3D3D646F63756D656E7426262879743D542829292C652E746F702B3D79742E7363726F6C6C546F702C652E6C6566742B3D';
wwv_flow_imp.g_varchar2_table(230) := '79742E7363726F6C6C4C656674293A79743D5428292C43743D49287974297D4528243D562E636C6F6E654E6F6465282130292C6E2E67686F7374436C6173732C2131292C4528242C6E2E66616C6C6261636B436C6173732C2130292C4528242C6E2E6472';
wwv_flow_imp.g_varchar2_table(231) := '6167436C6173732C2130292C5328242C227472616E736974696F6E222C2222292C5328242C227472616E73666F726D222C2222292C5328242C22626F782D73697A696E67222C22626F726465722D626F7822292C5328242C226D617267696E222C30292C';
wwv_flow_imp.g_varchar2_table(232) := '5328242C22746F70222C652E746F70292C5328242C226C656674222C652E6C656674292C5328242C227769647468222C652E7769647468292C5328242C22686569676874222C652E686569676874292C5328242C226F706163697479222C22302E382229';
wwv_flow_imp.g_varchar2_table(233) := '2C5328242C22706F736974696F6E222C4D743F226162736F6C757465223A22666978656422292C5328242C227A496E646578222C2231303030303022292C5328242C22706F696E7465724576656E7473222C226E6F6E6522292C46742E67686F73743D24';
wwv_flow_imp.g_varchar2_table(234) := '2C742E617070656E644368696C642824292C5328242C227472616E73666F726D2D6F726967696E222C70742F7061727365496E7428242E7374796C652E7769647468292A3130302B222520222B66742F7061727365496E7428242E7374796C652E686569';
wwv_flow_imp.g_varchar2_table(235) := '676874292A3130302B222522297D7D2C5F6F6E4472616753746172743A66756E6374696F6E28742C65297B766172206E3D746869732C6F3D742E646174615472616E736665722C693D6E2E6F7074696F6E733B472822647261675374617274222C746869';
wwv_flow_imp.g_varchar2_table(236) := '732C7B6576743A747D292C46742E6576656E7443616E63656C65643F746869732E5F6F6E44726F7028293A284728227365747570436C6F6E65222C74686973292C46742E6576656E7443616E63656C65647C7C282865743D59285629292E72656D6F7665';
wwv_flow_imp.g_varchar2_table(237) := '4174747269627574652822696422292C65742E647261676761626C653D21312C65742E7374796C655B2277696C6C2D6368616E6765225D3D22222C746869732E5F68696465436C6F6E6528292C452865742C746869732E6F7074696F6E732E63686F7365';
wwv_flow_imp.g_varchar2_table(238) := '6E436C6173732C2131292C46742E636C6F6E653D6574292C6E2E636C6F6E6549643D4B74282866756E6374696F6E28297B472822636C6F6E65222C6E292C46742E6576656E7443616E63656C65647C7C286E2E6F7074696F6E732E72656D6F7665436C6F';
wwv_flow_imp.g_varchar2_table(239) := '6E654F6E486964657C7C512E696E736572744265666F72652865742C56292C6E2E5F68696465436C6F6E6528292C71287B736F727461626C653A6E2C6E616D653A22636C6F6E65227D29297D29292C657C7C4528562C692E64726167436C6173732C2130';
wwv_flow_imp.g_varchar2_table(240) := '292C653F2844743D21302C6E2E5F6C6F6F7049643D736574496E74657276616C286E2E5F656D756C617465447261674F7665722C353029293A286D28646F63756D656E742C226D6F7573657570222C6E2E5F6F6E44726F70292C6D28646F63756D656E74';
wwv_flow_imp.g_varchar2_table(241) := '2C22746F756368656E64222C6E2E5F6F6E44726F70292C6D28646F63756D656E742C22746F75636863616E63656C222C6E2E5F6F6E44726F70292C6F2626286F2E656666656374416C6C6F7765643D226D6F7665222C692E736574446174612626692E73';
wwv_flow_imp.g_varchar2_table(242) := '6574446174612E63616C6C286E2C6F2C5629292C6728646F63756D656E742C2264726F70222C6E292C5328562C227472616E73666F726D222C227472616E736C6174655A2830292229292C77743D21302C6E2E5F64726167537461727449643D4B74286E';
wwv_flow_imp.g_varchar2_table(243) := '2E5F64726167537461727465642E62696E64286E2C652C7429292C6728646F63756D656E742C2273656C6563747374617274222C6E292C67743D21302C77696E646F772E67657453656C656374696F6E28292E72656D6F7665416C6C52616E6765732829';
wwv_flow_imp.g_varchar2_table(244) := '2C6426265328646F63756D656E742E626F64792C22757365722D73656C656374222C226E6F6E652229297D2C5F6F6E447261674F7665723A66756E6374696F6E2874297B76617220652C6E2C6F2C722C612C6C3D746869732E656C2C733D742E74617267';
wwv_flow_imp.g_varchar2_table(245) := '65742C633D746869732E6F7074696F6E732C753D632E67726F75702C643D46742E6163746976652C683D6C743D3D3D752C703D632E736F72742C663D73747C7C642C673D746869732C6D3D21313B696628215474297B696628766F69642030213D3D742E';
wwv_flow_imp.g_varchar2_table(246) := '70726576656E7444656661756C742626742E63616E63656C61626C652626742E70726576656E7444656661756C7428292C733D7928732C632E647261676761626C652C6C2C2130292C422822647261674F76657222292C46742E6576656E7443616E6365';
wwv_flow_imp.g_varchar2_table(247) := '6C65642972657475726E206D3B696628562E636F6E7461696E7328742E746172676574297C7C732E616E696D617465642626732E616E696D6174696E67582626732E616E696D6174696E67597C7C672E5F69676E6F72655768696C65416E696D6174696E';
wwv_flow_imp.g_varchar2_table(248) := '673D3D3D732972657475726E204C282131293B69662844743D21312C64262621632E64697361626C6564262628683F707C7C286E3D5A213D3D51293A73743D3D3D746869737C7C28746869732E6C6173745075744D6F64653D6C742E636865636B50756C';
wwv_flow_imp.g_varchar2_table(249) := '6C28746869732C642C562C7429292626752E636865636B50757428746869732C642C562C742929297B6966286F3D22766572746963616C223D3D3D746869732E5F676574446972656374696F6E28742C73292C653D782856292C422822647261674F7665';
wwv_flow_imp.g_varchar2_table(250) := '7256616C696422292C46742E6576656E7443616E63656C65642972657475726E206D3B6966286E2972657475726E205A3D512C4628292C746869732E5F68696465436C6F6E6528292C42282272657665727422292C46742E6576656E7443616E63656C65';
wwv_flow_imp.g_varchar2_table(251) := '647C7C284A3F512E696E736572744265666F726528562C4A293A512E617070656E644368696C64285629292C4C282130293B76617220763D41286C2C632E647261676761626C65293B69662876262628543D742C753D6F2C593D7828412828433D746869';
wwv_flow_imp.g_varchar2_table(252) := '73292E656C2C432E6F7074696F6E732E647261676761626C6529292C433D6A28432E656C2C432E6F7074696F6E732C24292C2128753F542E636C69656E74583E432E72696768742B31307C7C542E636C69656E74593E592E626F74746F6D2626542E636C';
wwv_flow_imp.g_varchar2_table(253) := '69656E74583E592E6C6566743A542E636C69656E74593E432E626F74746F6D2B31307C7C542E636C69656E74583E592E72696768742626542E636C69656E74593E592E746F70297C7C762E616E696D6174656429297B69662876262628723D742C613D6F';
wwv_flow_imp.g_varchar2_table(254) := '2C503D78284D2828493D74686973292E656C2C302C492E6F7074696F6E732C213029292C493D6A28492E656C2C492E6F7074696F6E732C24292C613F722E636C69656E74583C492E6C6566742D31307C7C722E636C69656E74593C502E746F702626722E';
wwv_flow_imp.g_varchar2_table(255) := '636C69656E74583C502E72696768743A722E636C69656E74593C492E746F702D31307C7C722E636C69656E74593C502E626F74746F6D2626722E636C69656E74583C502E6C65667429297B696628286B3D4D286C2C302C632C213029293D3D3D56297265';
wwv_flow_imp.g_varchar2_table(256) := '7475726E204C282131293B6966285F3D7828733D6B292C2131213D3D6A7428512C6C2C562C652C732C5F2C742C2131292972657475726E204628292C6C2E696E736572744265666F726528562C6B292C5A3D6C2C4B28292C4C282130297D656C73652069';
wwv_flow_imp.g_varchar2_table(257) := '6628732E706172656E744E6F64653D3D3D6C297B76617220622C772C442C5F3D782873292C433D562E706172656E744E6F6465213D3D6C2C543D28543D562E616E696D617465642626562E746F526563747C7C652C593D732E616E696D61746564262673';
wwv_flow_imp.g_varchar2_table(258) := '2E746F526563747C7C5F2C493D28613D6F293F542E6C6566743A542E746F702C723D613F542E72696768743A542E626F74746F6D2C503D613F542E77696474683A542E6865696768742C6B3D613F592E6C6566743A592E746F702C543D613F592E726967';
wwv_flow_imp.g_varchar2_table(259) := '68743A592E626F74746F6D2C593D613F592E77696474683A592E6865696768742C2128493D3D3D6B7C7C723D3D3D547C7C492B502F323D3D3D6B2B592F3229292C493D6F3F22746F70223A226C656674222C503D4F28732C22746F70222C22746F702229';
wwv_flow_imp.g_varchar2_table(260) := '7C7C4F28562C22746F70222C22746F7022292C6B3D503F502E7363726F6C6C546F703A766F696420303B6966286D74213D3D73262628773D5F5B495D2C53743D21312C5F743D21542626632E696E76657274537761707C7C43292C30213D3D28623D6675';
wwv_flow_imp.g_varchar2_table(261) := '6E6374696F6E28742C652C6E2C6F2C692C722C612C6C297B76617220733D6F3F742E636C69656E74593A742E636C69656E74582C633D6F3F6E2E6865696768743A6E2E77696474683B743D6F3F6E2E746F703A6E2E6C6566742C6F3D6F3F6E2E626F7474';
wwv_flow_imp.g_varchar2_table(262) := '6F6D3A6E2E72696768742C6E3D21313B6966282161296966286C262662743C632A69297B69662853743D215374262628313D3D3D76743F742B632A722F323C733A733C6F2D632A722F32297C7C5374296E3D21303B656C736520696628313D3D3D76743F';
wwv_flow_imp.g_varchar2_table(263) := '733C742B62743A6F2D62743C732972657475726E2D76747D656C736520696628742B632A28312D69292F323C732626733C6F2D632A28312D69292F322972657475726E2066756E6374696F6E2874297B72657475726E204E2856293C4E2874293F313A2D';
wwv_flow_imp.g_varchar2_table(264) := '317D2865293B72657475726E286E3D6E7C7C6129262628733C742B632A722F327C7C6F2D632A722F323C73293F742B632F323C733F313A2D313A307D28742C732C5F2C6F2C543F313A632E737761705468726573686F6C642C6E756C6C3D3D632E696E76';
wwv_flow_imp.g_varchar2_table(265) := '6572746564537761705468726573686F6C643F632E737761705468726573686F6C643A632E696E766572746564537761705468726573686F6C642C5F742C6D743D3D3D73292929666F722876617220523D4E2856293B28443D5A2E6368696C6472656E5B';
wwv_flow_imp.g_varchar2_table(266) := '522D3D625D29262628226E6F6E65223D3D3D5328442C22646973706C617922297C7C443D3D3D24293B293B696628303D3D3D627C7C443D3D3D732972657475726E204C282131293B76743D623B76617220593D286D743D73292E6E657874456C656D656E';
wwv_flow_imp.g_varchar2_table(267) := '745369626C696E673B433D21313B6966282131213D3D28543D6A7428512C6C2C562C652C732C5F2C742C433D313D3D3D6229292972657475726E2031213D3D5426262D31213D3D547C7C28433D313D3D3D54292C54743D21302C73657454696D656F7574';
wwv_flow_imp.g_varchar2_table(268) := '284C742C3330292C4628292C43262621593F6C2E617070656E644368696C642856293A732E706172656E744E6F64652E696E736572744265666F726528562C433F593A73292C5026265828502C302C6B2D502E7363726F6C6C546F70292C5A3D562E7061';
wwv_flow_imp.g_varchar2_table(269) := '72656E744E6F64652C766F696420303D3D3D777C7C5F747C7C2862743D4D6174682E61627328772D782873295B495D29292C4B28292C4C282130297D7D656C73657B696628763D3D3D562972657475726E204C282131293B69662828733D7626266C3D3D';
wwv_flow_imp.g_varchar2_table(270) := '3D742E7461726765743F763A73292626285F3D78287329292C2131213D3D6A7428512C6C2C562C652C732C5F2C742C212173292972657475726E204628292C762626762E6E6578745369626C696E673F6C2E696E736572744265666F726528562C762E6E';
wwv_flow_imp.g_varchar2_table(271) := '6578745369626C696E67293A6C2E617070656E644368696C642856292C5A3D6C2C4B28292C4C282130297D6966286C2E636F6E7461696E732856292972657475726E204C282131297D72657475726E21317D66756E6374696F6E204228722C61297B4728';
wwv_flow_imp.g_varchar2_table(272) := '722C672C69287B6576743A742C69734F776E65723A682C617869733A6F3F22766572746963616C223A22686F72697A6F6E74616C222C7265766572743A6E2C64726167526563743A652C746172676574526563743A5F2C63616E536F72743A702C66726F';
wwv_flow_imp.g_varchar2_table(273) := '6D536F727461626C653A662C7461726765743A732C636F6D706C657465643A4C2C6F6E4D6F76653A66756E6374696F6E286E2C6F297B72657475726E206A7428512C6C2C562C652C6E2C78286E292C742C6F297D2C6368616E6765643A4B7D2C6129297D';
wwv_flow_imp.g_varchar2_table(274) := '66756E6374696F6E204628297B422822647261674F766572416E696D6174696F6E4361707475726522292C672E63617074757265416E696D6174696F6E537461746528292C67213D3D662626662E63617074757265416E696D6174696F6E537461746528';
wwv_flow_imp.g_varchar2_table(275) := '297D66756E6374696F6E204C2865297B72657475726E20422822647261674F766572436F6D706C65746564222C7B696E73657274696F6E3A657D292C65262628683F642E5F68696465436C6F6E6528293A642E5F73686F77436C6F6E652867292C67213D';
wwv_flow_imp.g_varchar2_table(276) := '3D662626284528562C2873747C7C64292E6F7074696F6E732E67686F7374436C6173732C2131292C4528562C632E67686F7374436C6173732C213029292C7374213D3D67262667213D3D46742E6163746976653F73743D673A673D3D3D46742E61637469';
wwv_flow_imp.g_varchar2_table(277) := '76652626737426262873743D6E756C6C292C663D3D3D67262628672E5F69676E6F72655768696C65416E696D6174696E673D73292C672E616E696D617465416C6C282866756E6374696F6E28297B422822647261674F766572416E696D6174696F6E436F';
wwv_flow_imp.g_varchar2_table(278) := '6D706C65746522292C672E5F69676E6F72655768696C65416E696D6174696E673D6E756C6C7D29292C67213D3D66262628662E616E696D617465416C6C28292C662E5F69676E6F72655768696C65416E696D6174696E673D6E756C6C29292C28733D3D3D';
wwv_flow_imp.g_varchar2_table(279) := '56262621562E616E696D617465647C7C733D3D3D6C262621732E616E696D61746564292626286D743D6E756C6C292C632E647261676F766572427562626C657C7C742E726F6F74456C7C7C733D3D3D646F63756D656E747C7C28562E706172656E744E6F';
wwv_flow_imp.g_varchar2_table(280) := '64655B485D2E5F69734F75747369646554686973456C28742E746172676574292C657C7C5974287429292C21632E647261676F766572427562626C652626742E73746F7050726F7061676174696F6E2626742E73746F7050726F7061676174696F6E2829';
wwv_flow_imp.g_varchar2_table(281) := '2C6D3D21307D66756E6374696F6E204B28297B69743D4E2856292C61743D4E28562C632E647261676761626C65292C71287B736F727461626C653A672C6E616D653A226368616E6765222C746F456C3A6C2C6E6577496E6465783A69742C6E6577447261';
wwv_flow_imp.g_varchar2_table(282) := '676761626C65496E6465783A61742C6F726967696E616C4576656E743A747D297D7D2C5F69676E6F72655768696C65416E696D6174696E673A6E756C6C2C5F6F66664D6F76654576656E74733A66756E6374696F6E28297B6D28646F63756D656E742C22';
wwv_flow_imp.g_varchar2_table(283) := '6D6F7573656D6F7665222C746869732E5F6F6E546F7563684D6F7665292C6D28646F63756D656E742C22746F7563686D6F7665222C746869732E5F6F6E546F7563684D6F7665292C6D28646F63756D656E742C22706F696E7465726D6F7665222C746869';
wwv_flow_imp.g_varchar2_table(284) := '732E5F6F6E546F7563684D6F7665292C6D28646F63756D656E742C22647261676F766572222C5974292C6D28646F63756D656E742C226D6F7573656D6F7665222C5974292C6D28646F63756D656E742C22746F7563686D6F7665222C5974297D2C5F6F66';
wwv_flow_imp.g_varchar2_table(285) := '6655704576656E74733A66756E6374696F6E28297B76617220743D746869732E656C2E6F776E6572446F63756D656E743B6D28742C226D6F7573657570222C746869732E5F6F6E44726F70292C6D28742C22746F756368656E64222C746869732E5F6F6E';
wwv_flow_imp.g_varchar2_table(286) := '44726F70292C6D28742C22706F696E7465727570222C746869732E5F6F6E44726F70292C6D28742C22706F696E74657263616E63656C222C746869732E5F6F6E44726F70292C6D28742C22746F75636863616E63656C222C746869732E5F6F6E44726F70';
wwv_flow_imp.g_varchar2_table(287) := '292C6D28646F63756D656E742C2273656C6563747374617274222C74686973297D2C5F6F6E44726F703A66756E6374696F6E2874297B76617220653D746869732E656C2C6E3D746869732E6F7074696F6E733B69743D4E2856292C61743D4E28562C6E2E';
wwv_flow_imp.g_varchar2_table(288) := '647261676761626C65292C47282264726F70222C746869732C7B6576743A747D292C5A3D562626562E706172656E744E6F64652C69743D4E2856292C61743D4E28562C6E2E647261676761626C65292C46742E6576656E7443616E63656C65647C7C2853';
wwv_flow_imp.g_varchar2_table(289) := '743D5F743D77743D21312C636C656172496E74657276616C28746869732E5F6C6F6F704964292C636C65617254696D656F757428746869732E5F64726167537461727454696D6572292C577428746869732E636C6F6E654964292C577428746869732E5F';
wwv_flow_imp.g_varchar2_table(290) := '6472616753746172744964292C746869732E6E6174697665447261676761626C652626286D28646F63756D656E742C2264726F70222C74686973292C6D28652C22647261677374617274222C746869732E5F6F6E44726167537461727429292C74686973';
wwv_flow_imp.g_varchar2_table(291) := '2E5F6F66664D6F76654576656E747328292C746869732E5F6F666655704576656E747328292C6426265328646F63756D656E742E626F64792C22757365722D73656C656374222C2222292C5328562C227472616E73666F726D222C2222292C7426262867';
wwv_flow_imp.g_varchar2_table(292) := '74262628742E63616E63656C61626C652626742E70726576656E7444656661756C7428292C6E2E64726F70427562626C657C7C742E73746F7050726F7061676174696F6E2829292C242626242E706172656E744E6F64652626242E706172656E744E6F64';
wwv_flow_imp.g_varchar2_table(293) := '652E72656D6F76654368696C642824292C28513D3D3D5A7C7C7374262622636C6F6E6522213D3D73742E6C6173745075744D6F64652926266574262665742E706172656E744E6F6465262665742E706172656E744E6F64652E72656D6F76654368696C64';
wwv_flow_imp.g_varchar2_table(294) := '286574292C56262628746869732E6E6174697665447261676761626C6526266D28562C2264726167656E64222C74686973292C48742856292C562E7374796C655B2277696C6C2D6368616E6765225D3D22222C6774262621777426264528562C2873747C';
wwv_flow_imp.g_varchar2_table(295) := '7C74686973292E6F7074696F6E732E67686F7374436C6173732C2131292C4528562C746869732E6F7074696F6E732E63686F73656E436C6173732C2131292C71287B736F727461626C653A746869732C6E616D653A22756E63686F6F7365222C746F456C';
wwv_flow_imp.g_varchar2_table(296) := '3A5A2C6E6577496E6465783A6E756C6C2C6E6577447261676761626C65496E6465783A6E756C6C2C6F726967696E616C4576656E743A747D292C51213D3D5A3F28303C3D697426262871287B726F6F74456C3A5A2C6E616D653A22616464222C746F456C';
wwv_flow_imp.g_varchar2_table(297) := '3A5A2C66726F6D456C3A512C6F726967696E616C4576656E743A747D292C71287B736F727461626C653A746869732C6E616D653A2272656D6F7665222C746F456C3A5A2C6F726967696E616C4576656E743A747D292C71287B726F6F74456C3A5A2C6E61';
wwv_flow_imp.g_varchar2_table(298) := '6D653A22736F7274222C746F456C3A5A2C66726F6D456C3A512C6F726967696E616C4576656E743A747D292C71287B736F727461626C653A746869732C6E616D653A22736F7274222C746F456C3A5A2C6F726967696E616C4576656E743A747D29292C73';
wwv_flow_imp.g_varchar2_table(299) := '74262673742E736176652829293A6974213D3D6F742626303C3D697426262871287B736F727461626C653A746869732C6E616D653A22757064617465222C746F456C3A5A2C6F726967696E616C4576656E743A747D292C71287B736F727461626C653A74';
wwv_flow_imp.g_varchar2_table(300) := '6869732C6E616D653A22736F7274222C746F456C3A5A2C6F726967696E616C4576656E743A747D29292C46742E6163746976652626286E756C6C213D697426262D31213D3D69747C7C2869743D6F742C61743D7274292C71287B736F727461626C653A74';
wwv_flow_imp.g_varchar2_table(301) := '6869732C6E616D653A22656E64222C746F456C3A5A2C6F726967696E616C4576656E743A747D292C746869732E736176652829292929292C746869732E5F6E756C6C696E6728297D2C5F6E756C6C696E673A66756E6374696F6E28297B4728226E756C6C';
wwv_flow_imp.g_varchar2_table(302) := '696E67222C74686973292C513D563D5A3D243D4A3D65743D74743D6E743D63743D75743D67743D69743D61743D6F743D72743D6D743D76743D73743D6C743D46742E647261676765643D46742E67686F73743D46742E636C6F6E653D46742E6163746976';
wwv_flow_imp.g_varchar2_table(303) := '653D6E756C6C3B76617220743D746869732E656C3B78742E666F7245616368282866756E6374696F6E2865297B742E636F6E7461696E73286529262628652E636865636B65643D2130297D29292C78742E6C656E6774683D64743D68743D307D2C68616E';
wwv_flow_imp.g_varchar2_table(304) := '646C654576656E743A66756E6374696F6E2874297B73776974636828742E74797065297B636173652264726F70223A636173652264726167656E64223A746869732E5F6F6E44726F702874293B627265616B3B636173652264726167656E746572223A63';
wwv_flow_imp.g_varchar2_table(305) := '61736522647261676F766572223A56262628746869732E5F6F6E447261674F7665722874292C66756E6374696F6E2874297B742E646174615472616E73666572262628742E646174615472616E736665722E64726F704566666563743D226D6F76652229';
wwv_flow_imp.g_varchar2_table(306) := '2C742E63616E63656C61626C652626742E70726576656E7444656661756C7428297D287429293B627265616B3B636173652273656C6563747374617274223A742E70726576656E7444656661756C7428297D7D2C746F41727261793A66756E6374696F6E';
wwv_flow_imp.g_varchar2_table(307) := '28297B666F722876617220742C653D5B5D2C6E3D746869732E656C2E6368696C6472656E2C6F3D302C693D6E2E6C656E6774682C723D746869732E6F7074696F6E733B6F3C693B6F2B2B297928743D6E5B6F5D2C722E647261676761626C652C74686973';
wwv_flow_imp.g_varchar2_table(308) := '2E656C2C2131292626652E7075736828742E67657441747472696275746528722E64617461496441747472297C7C66756E6374696F6E2874297B666F722876617220653D742E7461674E616D652B742E636C6173734E616D652B742E7372632B742E6872';
wwv_flow_imp.g_varchar2_table(309) := '65662B742E74657874436F6E74656E742C6E3D652E6C656E6774682C6F3D303B6E2D2D3B296F2B3D652E63686172436F64654174286E293B72657475726E206F2E746F537472696E67283336297D287429293B72657475726E20657D2C736F72743A6675';
wwv_flow_imp.g_varchar2_table(310) := '6E6374696F6E28742C65297B766172206E3D7B7D2C6F3D746869732E656C3B746869732E746F417272617928292E666F7245616368282866756E6374696F6E28742C65297B7928653D6F2E6368696C6472656E5B655D2C746869732E6F7074696F6E732E';
wwv_flow_imp.g_varchar2_table(311) := '647261676761626C652C6F2C2131292626286E5B745D3D65297D292C74686973292C652626746869732E63617074757265416E696D6174696F6E537461746528292C742E666F7245616368282866756E6374696F6E2874297B6E5B745D2626286F2E7265';
wwv_flow_imp.g_varchar2_table(312) := '6D6F76654368696C64286E5B745D292C6F2E617070656E644368696C64286E5B745D29297D29292C652626746869732E616E696D617465416C6C28297D2C736176653A66756E6374696F6E28297B76617220743D746869732E6F7074696F6E732E73746F';
wwv_flow_imp.g_varchar2_table(313) := '72653B742626742E7365742626742E7365742874686973297D2C636C6F736573743A66756E6374696F6E28742C65297B72657475726E207928742C657C7C746869732E6F7074696F6E732E647261676761626C652C746869732E656C2C2131297D2C6F70';
wwv_flow_imp.g_varchar2_table(314) := '74696F6E3A66756E6374696F6E28742C65297B766172206E3D746869732E6F7074696F6E733B696628766F696420303D3D3D652972657475726E206E5B745D3B766172206F3D572E6D6F646966794F7074696F6E28746869732C742C65293B6E5B745D3D';
wwv_flow_imp.g_varchar2_table(315) := '766F69642030213D3D6F3F6F3A652C2267726F7570223D3D3D7426266B74286E297D2C64657374726F793A66756E6374696F6E28297B47282264657374726F79222C74686973293B76617220743D746869732E656C3B745B485D3D6E756C6C2C6D28742C';
wwv_flow_imp.g_varchar2_table(316) := '226D6F757365646F776E222C746869732E5F6F6E5461705374617274292C6D28742C22746F7563687374617274222C746869732E5F6F6E5461705374617274292C6D28742C22706F696E746572646F776E222C746869732E5F6F6E546170537461727429';
wwv_flow_imp.g_varchar2_table(317) := '2C746869732E6E6174697665447261676761626C652626286D28742C22647261676F766572222C74686973292C6D28742C2264726167656E746572222C7468697329292C41727261792E70726F746F747970652E666F72456163682E63616C6C28742E71';
wwv_flow_imp.g_varchar2_table(318) := '7565727953656C6563746F72416C6C28225B647261676761626C655D22292C2866756E6374696F6E2874297B742E72656D6F76654174747269627574652822647261676761626C6522297D29292C746869732E5F6F6E44726F7028292C746869732E5F64';
wwv_flow_imp.g_varchar2_table(319) := '697361626C6544656C61796564447261674576656E747328292C45742E73706C6963652845742E696E6465784F6628746869732E656C292C31292C746869732E656C3D743D6E756C6C7D2C5F68696465436C6F6E653A66756E6374696F6E28297B6E747C';
wwv_flow_imp.g_varchar2_table(320) := '7C2847282268696465436C6F6E65222C74686973292C46742E6576656E7443616E63656C65647C7C28532865742C22646973706C6179222C226E6F6E6522292C746869732E6F7074696F6E732E72656D6F7665436C6F6E654F6E48696465262665742E70';
wwv_flow_imp.g_varchar2_table(321) := '6172656E744E6F6465262665742E706172656E744E6F64652E72656D6F76654368696C64286574292C6E743D213029297D2C5F73686F77436C6F6E653A66756E6374696F6E2874297B22636C6F6E65223D3D3D742E6C6173745075744D6F64653F6E7426';
wwv_flow_imp.g_varchar2_table(322) := '262847282273686F77436C6F6E65222C74686973292C46742E6576656E7443616E63656C65647C7C28562E706172656E744E6F6465213D517C7C746869732E6F7074696F6E732E67726F75702E726576657274436C6F6E653F4A3F512E696E7365727442';
wwv_flow_imp.g_varchar2_table(323) := '65666F72652865742C4A293A512E617070656E644368696C64286574293A512E696E736572744265666F72652865742C56292C746869732E6F7074696F6E732E67726F75702E726576657274436C6F6E652626746869732E616E696D61746528562C6574';
wwv_flow_imp.g_varchar2_table(324) := '292C532865742C22646973706C6179222C2222292C6E743D213129293A746869732E5F68696465436C6F6E6528297D7D2C4F7426266728646F63756D656E742C22746F7563686D6F7665222C2866756E6374696F6E2874297B2846742E6163746976657C';
wwv_flow_imp.g_varchar2_table(325) := '7C7774292626742E63616E63656C61626C652626742E70726576656E7444656661756C7428297D29292C46742E7574696C733D7B6F6E3A672C6F66663A6D2C6373733A532C66696E643A432C69733A66756E6374696F6E28742C65297B72657475726E21';
wwv_flow_imp.g_varchar2_table(326) := '217928742C652C742C2131297D2C657874656E643A66756E6374696F6E28742C65297B6966287426266529666F7228766172206E20696E206529652E6861734F776E50726F7065727479286E29262628745B6E5D3D655B6E5D293B72657475726E20747D';
wwv_flow_imp.g_varchar2_table(327) := '2C7468726F74746C653A522C636C6F736573743A792C746F67676C65436C6173733A452C636C6F6E653A592C696E6465783A4E2C6E6578745469636B3A4B742C63616E63656C4E6578745469636B3A57742C646574656374446972656374696F6E3A5074';
wwv_flow_imp.g_varchar2_table(328) := '2C6765744368696C643A4D2C657870616E646F3A487D2C46742E6765743D66756E6374696F6E2874297B72657475726E20745B485D7D2C46742E6D6F756E743D66756E6374696F6E28297B666F722876617220743D617267756D656E74732E6C656E6774';
wwv_flow_imp.g_varchar2_table(329) := '682C653D6E65772041727261792874292C6E3D303B6E3C743B6E2B2B29655B6E5D3D617267756D656E74735B6E5D3B28653D655B305D2E636F6E7374727563746F723D3D3D41727261793F655B305D3A65292E666F7245616368282866756E6374696F6E';
wwv_flow_imp.g_varchar2_table(330) := '2874297B69662821742E70726F746F747970657C7C21742E70726F746F747970652E636F6E7374727563746F72297468726F7722536F727461626C653A204D6F756E74656420706C7567696E206D757374206265206120636F6E7374727563746F722066';
wwv_flow_imp.g_varchar2_table(331) := '756E6374696F6E2C206E6F7420222E636F6E636174287B7D2E746F537472696E672E63616C6C287429293B742E7574696C7326262846742E7574696C733D692869287B7D2C46742E7574696C73292C742E7574696C7329292C572E6D6F756E742874297D';
wwv_flow_imp.g_varchar2_table(332) := '29297D2C46742E6372656174653D66756E6374696F6E28742C65297B72657475726E206E657720467428742C65297D3B766172207A742C47742C55742C71742C56742C5A742C24743D5B5D2C51743D212846742E76657273696F6E3D22312E31352E3722';
wwv_flow_imp.g_varchar2_table(333) := '293B66756E6374696F6E204A7428297B24742E666F7245616368282866756E6374696F6E2874297B636C656172496E74657276616C28742E706964297D29292C24743D5B5D7D66756E6374696F6E20746528297B636C656172496E74657276616C285A74';
wwv_flow_imp.g_varchar2_table(334) := '297D7661722065652C6E653D52282866756E6374696F6E28742C652C6E2C6F297B696628652E7363726F6C6C297B76617220692C723D28742E746F75636865733F742E746F75636865735B305D3A74292E636C69656E74582C613D28742E746F75636865';
wwv_flow_imp.g_varchar2_table(335) := '733F742E746F75636865735B305D3A74292E636C69656E74592C6C3D652E7363726F6C6C53656E73697469766974792C733D652E7363726F6C6C53706565642C633D5428292C753D21313B4774213D3D6E26262847743D6E2C4A7428292C7A743D652E73';
wwv_flow_imp.g_varchar2_table(336) := '63726F6C6C2C693D652E7363726F6C6C466E2C21303D3D3D7A742626287A743D50286E2C21302929293B76617220643D302C683D7A743B646F7B76617220703D682C663D284F3D78287029292E746F702C673D4F2E626F74746F6D2C6D3D4F2E6C656674';
wwv_flow_imp.g_varchar2_table(337) := '2C763D4F2E72696768742C623D4F2E77696474682C793D4F2E6865696768742C773D766F696420302C443D702E7363726F6C6C57696474682C453D702E7363726F6C6C4865696768742C5F3D532870292C433D702E7363726F6C6C4C6566742C4F3D702E';
wwv_flow_imp.g_varchar2_table(338) := '7363726F6C6C546F702C4D3D703D3D3D633F28773D623C44262628226175746F223D3D3D5F2E6F766572666C6F77587C7C227363726F6C6C223D3D3D5F2E6F766572666C6F77587C7C2276697369626C65223D3D3D5F2E6F766572666C6F7758292C793C';
wwv_flow_imp.g_varchar2_table(339) := '45262628226175746F223D3D3D5F2E6F766572666C6F77597C7C227363726F6C6C223D3D3D5F2E6F766572666C6F77597C7C2276697369626C65223D3D3D5F2E6F766572666C6F775929293A28773D623C44262628226175746F223D3D3D5F2E6F766572';
wwv_flow_imp.g_varchar2_table(340) := '666C6F77587C7C227363726F6C6C223D3D3D5F2E6F766572666C6F7758292C793C45262628226175746F223D3D3D5F2E6F766572666C6F77597C7C227363726F6C6C223D3D3D5F2E6F766572666C6F775929293B433D772626284D6174682E6162732876';
wwv_flow_imp.g_varchar2_table(341) := '2D72293C3D6C2626432B623C44292D284D6174682E616273286D2D72293C3D6C2626212143292C4F3D4D2626284D6174682E61627328672D61293C3D6C26264F2B793C45292D284D6174682E61627328662D61293C3D6C262621214F293B696628212474';
wwv_flow_imp.g_varchar2_table(342) := '5B645D29666F722876617220413D303B413C3D643B412B2B2924745B415D7C7C2824745B415D3D7B7D293B24745B645D2E76783D3D43262624745B645D2E76793D3D4F262624745B645D2E656C3D3D3D707C7C2824745B645D2E656C3D702C24745B645D';
wwv_flow_imp.g_varchar2_table(343) := '2E76783D432C24745B645D2E76793D4F2C636C656172496E74657276616C2824745B645D2E706964292C303D3D432626303D3D4F7C7C28753D21302C24745B645D2E7069643D736574496E74657276616C2866756E6374696F6E28297B6F2626303D3D3D';
wwv_flow_imp.g_varchar2_table(344) := '746869732E6C61796572262646742E6163746976652E5F6F6E546F7563684D6F7665285674293B76617220653D24745B746869732E6C617965725D2E76793F24745B746869732E6C617965725D2E76792A733A302C6E3D24745B746869732E6C61796572';
wwv_flow_imp.g_varchar2_table(345) := '5D2E76783F24745B746869732E6C617965725D2E76782A733A303B2266756E6374696F6E223D3D747970656F662069262622636F6E74696E756522213D3D692E63616C6C2846742E647261676765642E706172656E744E6F64655B485D2C6E2C652C742C';
wwv_flow_imp.g_varchar2_table(346) := '56742C24745B746869732E6C617965725D2E656C297C7C582824745B746869732E6C617965725D2E656C2C6E2C65297D2E62696E64287B6C617965723A647D292C32342929292C642B2B7D7768696C6528652E627562626C655363726F6C6C262668213D';
wwv_flow_imp.g_varchar2_table(347) := '3D63262628683D5028682C21312929293B51743D757D7D292C3330293B703D66756E6374696F6E2874297B76617220653D742E6F726967696E616C4576656E742C6E3D742E707574536F727461626C652C6F3D742E64726167456C2C693D742E61637469';
wwv_flow_imp.g_varchar2_table(348) := '7665536F727461626C652C723D742E6469737061746368536F727461626C654576656E742C613D742E6869646547686F7374466F725461726765743B743D742E756E6869646547686F7374466F725461726765743B65262628693D6E7C7C692C6128292C';
wwv_flow_imp.g_varchar2_table(349) := '653D652E6368616E676564546F75636865732626652E6368616E676564546F75636865732E6C656E6774683F652E6368616E676564546F75636865735B305D3A652C653D646F63756D656E742E656C656D656E7446726F6D506F696E7428652E636C6965';
wwv_flow_imp.g_varchar2_table(350) := '6E74582C652E636C69656E7459292C7428292C69262621692E656C2E636F6E7461696E732865292626287228227370696C6C22292C746869732E6F6E5370696C6C287B64726167456C3A6F2C707574536F727461626C653A6E7D2929297D3B66756E6374';
wwv_flow_imp.g_varchar2_table(351) := '696F6E206F6528297B7D66756E6374696F6E20696528297B7D6F652E70726F746F747970653D7B7374617274496E6465783A6E756C6C2C6472616753746172743A66756E6374696F6E2874297B743D742E6F6C64447261676761626C65496E6465782C74';
wwv_flow_imp.g_varchar2_table(352) := '6869732E7374617274496E6465783D747D2C6F6E5370696C6C3A66756E6374696F6E2874297B76617220653D742E64726167456C2C6E3D742E707574536F727461626C653B746869732E736F727461626C652E63617074757265416E696D6174696F6E53';
wwv_flow_imp.g_varchar2_table(353) := '7461746528292C6E26266E2E63617074757265416E696D6174696F6E537461746528292C28743D4D28746869732E736F727461626C652E656C2C746869732E7374617274496E6465782C746869732E6F7074696F6E7329293F746869732E736F72746162';
wwv_flow_imp.g_varchar2_table(354) := '6C652E656C2E696E736572744265666F726528652C74293A746869732E736F727461626C652E656C2E617070656E644368696C642865292C746869732E736F727461626C652E616E696D617465416C6C28292C6E26266E2E616E696D617465416C6C2829';
wwv_flow_imp.g_varchar2_table(355) := '7D2C64726F703A707D2C6E286F652C7B706C7567696E4E616D653A227265766572744F6E5370696C6C227D292C69652E70726F746F747970653D7B6F6E5370696C6C3A66756E6374696F6E2874297B76617220653D742E64726167456C3B28743D742E70';
wwv_flow_imp.g_varchar2_table(356) := '7574536F727461626C657C7C746869732E736F727461626C65292E63617074757265416E696D6174696F6E537461746528292C652E706172656E744E6F64652626652E706172656E744E6F64652E72656D6F76654368696C642865292C742E616E696D61';
wwv_flow_imp.g_varchar2_table(357) := '7465416C6C28297D2C64726F703A707D2C6E2869652C7B706C7567696E4E616D653A2272656D6F76654F6E5370696C6C227D293B7661722072652C61652C6C652C73652C63652C75653D5B5D2C64653D5B5D2C68653D21312C70653D21312C66653D2131';
wwv_flow_imp.g_varchar2_table(358) := '3B66756E6374696F6E20676528742C65297B64652E666F7245616368282866756E6374696F6E286E2C6F297B286F3D652E6368696C6472656E5B6E2E736F727461626C65496E6465782B28743F4E756D626572286F293A30295D293F652E696E73657274';
wwv_flow_imp.g_varchar2_table(359) := '4265666F7265286E2C6F293A652E617070656E644368696C64286E297D29297D66756E6374696F6E206D6528297B75652E666F7245616368282866756E6374696F6E2874297B74213D3D6C652626742E706172656E744E6F64652626742E706172656E74';
wwv_flow_imp.g_varchar2_table(360) := '4E6F64652E72656D6F76654368696C642874297D29297D72657475726E2046742E6D6F756E74286E65772066756E6374696F6E28297B66756E6374696F6E207428297B666F7228766172207420696E20746869732E64656661756C74733D7B7363726F6C';
wwv_flow_imp.g_varchar2_table(361) := '6C3A21302C666F7263654175746F5363726F6C6C46616C6C6261636B3A21312C7363726F6C6C53656E73697469766974793A33302C7363726F6C6C53706565643A31302C627562626C655363726F6C6C3A21307D2C7468697329225F223D3D3D742E6368';
wwv_flow_imp.g_varchar2_table(362) := '6172417428302926262266756E6374696F6E223D3D747970656F6620746869735B745D262628746869735B745D3D746869735B745D2E62696E64287468697329297D72657475726E20742E70726F746F747970653D7B64726167537461727465643A6675';
wwv_flow_imp.g_varchar2_table(363) := '6E6374696F6E2874297B743D742E6F726967696E616C4576656E742C746869732E736F727461626C652E6E6174697665447261676761626C653F6728646F63756D656E742C22647261676F766572222C746869732E5F68616E646C654175746F5363726F';
wwv_flow_imp.g_varchar2_table(364) := '6C6C293A746869732E6F7074696F6E732E737570706F7274506F696E7465723F6728646F63756D656E742C22706F696E7465726D6F7665222C746869732E5F68616E646C6546616C6C6261636B4175746F5363726F6C6C293A742E746F75636865733F67';
wwv_flow_imp.g_varchar2_table(365) := '28646F63756D656E742C22746F7563686D6F7665222C746869732E5F68616E646C6546616C6C6261636B4175746F5363726F6C6C293A6728646F63756D656E742C226D6F7573656D6F7665222C746869732E5F68616E646C6546616C6C6261636B417574';
wwv_flow_imp.g_varchar2_table(366) := '6F5363726F6C6C297D2C647261674F766572436F6D706C657465643A66756E6374696F6E2874297B743D742E6F726967696E616C4576656E742C746869732E6F7074696F6E732E647261674F766572427562626C657C7C742E726F6F74456C7C7C746869';
wwv_flow_imp.g_varchar2_table(367) := '732E5F68616E646C654175746F5363726F6C6C2874297D2C64726F703A66756E6374696F6E28297B746869732E736F727461626C652E6E6174697665447261676761626C653F6D28646F63756D656E742C22647261676F766572222C746869732E5F6861';
wwv_flow_imp.g_varchar2_table(368) := '6E646C654175746F5363726F6C6C293A286D28646F63756D656E742C22706F696E7465726D6F7665222C746869732E5F68616E646C6546616C6C6261636B4175746F5363726F6C6C292C6D28646F63756D656E742C22746F7563686D6F7665222C746869';
wwv_flow_imp.g_varchar2_table(369) := '732E5F68616E646C6546616C6C6261636B4175746F5363726F6C6C292C6D28646F63756D656E742C226D6F7573656D6F7665222C746869732E5F68616E646C6546616C6C6261636B4175746F5363726F6C6C29292C746528292C4A7428292C636C656172';
wwv_flow_imp.g_varchar2_table(370) := '54696D656F75742877292C773D766F696420307D2C6E756C6C696E673A66756E6374696F6E28297B56743D47743D7A743D51743D5A743D55743D71743D6E756C6C2C24742E6C656E6774683D307D2C5F68616E646C6546616C6C6261636B4175746F5363';
wwv_flow_imp.g_varchar2_table(371) := '726F6C6C3A66756E6374696F6E2874297B746869732E5F68616E646C654175746F5363726F6C6C28742C2130297D2C5F68616E646C654175746F5363726F6C6C3A66756E6374696F6E28742C65297B766172206E2C6F3D746869732C693D28742E746F75';
wwv_flow_imp.g_varchar2_table(372) := '636865733F742E746F75636865735B305D3A74292E636C69656E74582C723D28742E746F75636865733F742E746F75636865735B305D3A74292E636C69656E74592C613D646F63756D656E742E656C656D656E7446726F6D506F696E7428692C72293B56';
wwv_flow_imp.g_varchar2_table(373) := '743D742C657C7C746869732E6F7074696F6E732E666F7263654175746F5363726F6C6C46616C6C6261636B7C7C637C7C737C7C643F286E6528742C746869732E6F7074696F6E732C612C65292C6E3D5028612C2130292C2151747C7C5A742626693D3D3D';
wwv_flow_imp.g_varchar2_table(374) := '55742626723D3D3D71747C7C285A742626746528292C5A743D736574496E74657276616C282866756E6374696F6E28297B76617220613D5028646F63756D656E742E656C656D656E7446726F6D506F696E7428692C72292C2130293B61213D3D6E262628';
wwv_flow_imp.g_varchar2_table(375) := '6E3D612C4A742829292C6E6528742C6F2E6F7074696F6E732C612C65297D292C3130292C55743D692C71743D7229293A746869732E6F7074696F6E732E627562626C655363726F6C6C26265028612C213029213D3D5428293F6E6528742C746869732E6F';
wwv_flow_imp.g_varchar2_table(376) := '7074696F6E732C5028612C2131292C2131293A4A7428297D7D2C6E28742C7B706C7567696E4E616D653A227363726F6C6C222C696E697469616C697A65427944656661756C743A21307D297D292C46742E6D6F756E742869652C6F65292C46742E6D6F75';
wwv_flow_imp.g_varchar2_table(377) := '6E74286E65772066756E6374696F6E28297B66756E6374696F6E207428297B746869732E64656661756C74733D7B73776170436C6173733A22736F727461626C652D737761702D686967686C69676874227D7D72657475726E20742E70726F746F747970';
wwv_flow_imp.g_varchar2_table(378) := '653D7B6472616753746172743A66756E6374696F6E2874297B743D742E64726167456C2C65653D747D2C647261674F76657256616C69643A66756E6374696F6E2874297B76617220653D742E636F6D706C657465642C6E3D742E7461726765742C6F3D74';
wwv_flow_imp.g_varchar2_table(379) := '2E6F6E4D6F76652C693D742E616374697665536F727461626C652C723D742E6368616E6765642C613D742E63616E63656C3B692E6F7074696F6E732E73776170262628743D746869732E736F727461626C652E656C2C693D746869732E6F7074696F6E73';
wwv_flow_imp.g_varchar2_table(380) := '2C6E26266E213D3D74262628743D65652C65653D2131213D3D6F286E293F2845286E2C692E73776170436C6173732C2130292C6E293A6E756C6C2C74262674213D3D656526264528742C692E73776170436C6173732C213129292C7228292C6528213029';
wwv_flow_imp.g_varchar2_table(381) := '2C612829297D2C64726F703A66756E6374696F6E2874297B76617220652C6E2C6F3D742E616374697665536F727461626C652C693D742E707574536F727461626C652C723D742E64726167456C2C613D697C7C746869732E736F727461626C652C6C3D74';
wwv_flow_imp.g_varchar2_table(382) := '6869732E6F7074696F6E733B65652626452865652C6C2E73776170436C6173732C2131292C65652626286C2E737761707C7C692626692E6F7074696F6E732E7377617029262672213D3D6565262628612E63617074757265416E696D6174696F6E537461';
wwv_flow_imp.g_varchar2_table(383) := '746528292C61213D3D6F26266F2E63617074757265416E696D6174696F6E537461746528292C6E3D65652C743D28653D72292E706172656E744E6F64652C6C3D6E2E706172656E744E6F64652C7426266C262621742E6973457175616C4E6F6465286E29';
wwv_flow_imp.g_varchar2_table(384) := '2626216C2E6973457175616C4E6F6465286529262628693D4E2865292C723D4E286E292C742E6973457175616C4E6F6465286C292626693C722626722B2B2C742E696E736572744265666F7265286E2C742E6368696C6472656E5B695D292C6C2E696E73';
wwv_flow_imp.g_varchar2_table(385) := '6572744265666F726528652C6C2E6368696C6472656E5B725D29292C612E616E696D617465416C6C28292C61213D3D6F26266F2E616E696D617465416C6C2829297D2C6E756C6C696E673A66756E6374696F6E28297B65653D6E756C6C7D7D2C6E28742C';
wwv_flow_imp.g_varchar2_table(386) := '7B706C7567696E4E616D653A2273776170222C6576656E7450726F706572746965733A66756E6374696F6E28297B72657475726E7B737761704974656D3A65657D7D7D297D292C46742E6D6F756E74286E65772066756E6374696F6E28297B66756E6374';
wwv_flow_imp.g_varchar2_table(387) := '696F6E20742874297B666F7228766172206520696E207468697329225F223D3D3D652E63686172417428302926262266756E6374696F6E223D3D747970656F6620746869735B655D262628746869735B655D3D746869735B655D2E62696E642874686973';
wwv_flow_imp.g_varchar2_table(388) := '29293B742E6F7074696F6E732E61766F6964496D706C69636974446573656C6563747C7C28742E6F7074696F6E732E737570706F7274506F696E7465723F6728646F63756D656E742C22706F696E7465727570222C746869732E5F646573656C6563744D';
wwv_flow_imp.g_varchar2_table(389) := '756C746944726167293A286728646F63756D656E742C226D6F7573657570222C746869732E5F646573656C6563744D756C746944726167292C6728646F63756D656E742C22746F756368656E64222C746869732E5F646573656C6563744D756C74694472';
wwv_flow_imp.g_varchar2_table(390) := '61672929292C6728646F63756D656E742C226B6579646F776E222C746869732E5F636865636B4B6579446F776E292C6728646F63756D656E742C226B65797570222C746869732E5F636865636B4B65795570292C746869732E64656661756C74733D7B73';
wwv_flow_imp.g_varchar2_table(391) := '656C6563746564436C6173733A22736F727461626C652D73656C6563746564222C6D756C7469447261674B65793A6E756C6C2C61766F6964496D706C69636974446573656C6563743A21312C736574446174613A66756E6374696F6E28652C6E297B7661';
wwv_flow_imp.g_varchar2_table(392) := '72206F3D22223B75652E6C656E677468262661653D3D3D743F75652E666F7245616368282866756E6374696F6E28742C65297B6F2B3D28653F222C20223A2222292B742E74657874436F6E74656E747D29293A6F3D6E2E74657874436F6E74656E742C65';
wwv_flow_imp.g_varchar2_table(393) := '2E73657444617461282254657874222C6F297D7D7D72657475726E20742E70726F746F747970653D7B6D756C7469447261674B6579446F776E3A21312C69734D756C7469447261673A21312C64656C61795374617274476C6F62616C3A66756E6374696F';
wwv_flow_imp.g_varchar2_table(394) := '6E2874297B743D742E64726167456C2C6C653D747D2C64656C6179456E6465643A66756E6374696F6E28297B746869732E69734D756C7469447261673D7E75652E696E6465784F66286C65297D2C7365747570436C6F6E653A66756E6374696F6E287429';
wwv_flow_imp.g_varchar2_table(395) := '7B76617220653D742E736F727461626C653B743D742E63616E63656C3B696628746869732E69734D756C746944726167297B666F7228766172206E3D303B6E3C75652E6C656E6774683B6E2B2B2964652E7075736828592875655B6E5D29292C64655B6E';
wwv_flow_imp.g_varchar2_table(396) := '5D2E736F727461626C65496E6465783D75655B6E5D2E736F727461626C65496E6465782C64655B6E5D2E647261676761626C653D21312C64655B6E5D2E7374796C655B2277696C6C2D6368616E6765225D3D22222C452864655B6E5D2C746869732E6F70';
wwv_flow_imp.g_varchar2_table(397) := '74696F6E732E73656C6563746564436C6173732C2131292C75655B6E5D3D3D3D6C652626452864655B6E5D2C746869732E6F7074696F6E732E63686F73656E436C6173732C2131293B652E5F68696465436C6F6E6528292C7428297D7D2C636C6F6E653A';
wwv_flow_imp.g_varchar2_table(398) := '66756E6374696F6E2874297B76617220653D742E736F727461626C652C6E3D742E726F6F74456C2C6F3D742E6469737061746368536F727461626C654576656E743B743D742E63616E63656C3B746869732E69734D756C74694472616726262874686973';
wwv_flow_imp.g_varchar2_table(399) := '2E6F7074696F6E732E72656D6F7665436C6F6E654F6E486964657C7C75652E6C656E677468262661653D3D3D6526262867652821302C6E292C6F2822636C6F6E6522292C74282929297D2C73686F77436C6F6E653A66756E6374696F6E2874297B766172';
wwv_flow_imp.g_varchar2_table(400) := '20653D742E636C6F6E654E6F7753686F776E2C6E3D742E726F6F74456C3B743D742E63616E63656C3B746869732E69734D756C74694472616726262867652821312C6E292C64652E666F7245616368282866756E6374696F6E2874297B5328742C226469';
wwv_flow_imp.g_varchar2_table(401) := '73706C6179222C2222297D29292C6528292C63653D21312C742829297D2C68696465436C6F6E653A66756E6374696F6E2874297B76617220653D746869732C6E3D28742E736F727461626C652C742E636C6F6E654E6F7748696464656E293B743D742E63';
wwv_flow_imp.g_varchar2_table(402) := '616E63656C3B746869732E69734D756C74694472616726262864652E666F7245616368282866756E6374696F6E2874297B5328742C22646973706C6179222C226E6F6E6522292C652E6F7074696F6E732E72656D6F7665436C6F6E654F6E486964652626';
wwv_flow_imp.g_varchar2_table(403) := '742E706172656E744E6F64652626742E706172656E744E6F64652E72656D6F76654368696C642874297D29292C6E28292C63653D21302C742829297D2C647261675374617274476C6F62616C3A66756E6374696F6E2874297B742E736F727461626C652C';
wwv_flow_imp.g_varchar2_table(404) := '21746869732E69734D756C74694472616726266165262661652E6D756C7469447261672E5F646573656C6563744D756C74694472616728292C75652E666F7245616368282866756E6374696F6E2874297B742E736F727461626C65496E6465783D4E2874';
wwv_flow_imp.g_varchar2_table(405) := '297D29292C75653D75652E736F7274282866756E6374696F6E28742C65297B72657475726E20742E736F727461626C65496E6465782D652E736F727461626C65496E6465787D29292C66653D21307D2C64726167537461727465643A66756E6374696F6E';
wwv_flow_imp.g_varchar2_table(406) := '2874297B76617220652C6E3D746869733B743D742E736F727461626C653B746869732E69734D756C746944726167262628746869732E6F7074696F6E732E736F7274262628742E63617074757265416E696D6174696F6E537461746528292C746869732E';
wwv_flow_imp.g_varchar2_table(407) := '6F7074696F6E732E616E696D6174696F6E26262875652E666F7245616368282866756E6374696F6E2874297B74213D3D6C6526265328742C22706F736974696F6E222C226162736F6C75746522297D29292C653D78286C652C21312C21302C2130292C75';
wwv_flow_imp.g_varchar2_table(408) := '652E666F7245616368282866756E6374696F6E2874297B74213D3D6C6526264228742C65297D29292C68653D70653D213029292C742E616E696D617465416C6C282866756E6374696F6E28297B68653D70653D21312C6E2E6F7074696F6E732E616E696D';
wwv_flow_imp.g_varchar2_table(409) := '6174696F6E262675652E666F7245616368282866756E6374696F6E2874297B462874297D29292C6E2E6F7074696F6E732E736F727426266D6528297D2929297D2C647261674F7665723A66756E6374696F6E2874297B76617220653D742E746172676574';
wwv_flow_imp.g_varchar2_table(410) := '2C6E3D742E636F6D706C657465643B743D742E63616E63656C3B706526267E75652E696E6465784F662865292626286E282131292C742829297D2C7265766572743A66756E6374696F6E2874297B76617220652C6E2C6F3D742E66726F6D536F72746162';
wwv_flow_imp.g_varchar2_table(411) := '6C652C693D742E726F6F74456C2C723D742E736F727461626C652C613D742E64726167526563743B313C75652E6C656E67746826262875652E666F7245616368282866756E6374696F6E2874297B722E616464416E696D6174696F6E5374617465287B74';
wwv_flow_imp.g_varchar2_table(412) := '61726765743A742C726563743A70653F782874293A617D292C462874292C742E66726F6D526563743D612C6F2E72656D6F7665416E696D6174696F6E53746174652874297D29292C70653D21312C653D21746869732E6F7074696F6E732E72656D6F7665';
wwv_flow_imp.g_varchar2_table(413) := '436C6F6E654F6E486964652C6E3D692C75652E666F7245616368282866756E6374696F6E28742C6F297B286F3D6E2E6368696C6472656E5B742E736F727461626C65496E6465782B28653F4E756D626572286F293A30295D293F6E2E696E736572744265';
wwv_flow_imp.g_varchar2_table(414) := '666F726528742C6F293A6E2E617070656E644368696C642874297D2929297D2C647261674F766572436F6D706C657465643A66756E6374696F6E2874297B76617220652C6E3D742E736F727461626C652C6F3D742E69734F776E65722C693D742E696E73';
wwv_flow_imp.g_varchar2_table(415) := '657274696F6E2C723D742E616374697665536F727461626C652C613D742E706172656E74456C2C6C3D742E707574536F727461626C653B743D746869732E6F7074696F6E733B692626286F2626722E5F68696465436C6F6E6528292C68653D21312C742E';
wwv_flow_imp.g_varchar2_table(416) := '616E696D6174696F6E2626313C75652E6C656E67746826262870657C7C216F262621722E6F7074696F6E732E736F72742626216C29262628653D78286C652C21312C21302C2130292C75652E666F7245616368282866756E6374696F6E2874297B74213D';
wwv_flow_imp.g_varchar2_table(417) := '3D6C652626284228742C65292C612E617070656E644368696C64287429297D29292C70653D2130292C6F7C7C2870657C7C6D6528292C313C75652E6C656E6774683F286F3D63652C722E5F73686F77436C6F6E65286E292C722E6F7074696F6E732E616E';
wwv_flow_imp.g_varchar2_table(418) := '696D6174696F6E262621636526266F262664652E666F7245616368282866756E6374696F6E2874297B722E616464416E696D6174696F6E5374617465287B7461726765743A742C726563743A73657D292C742E66726F6D526563743D73652C742E746869';
wwv_flow_imp.g_varchar2_table(419) := '73416E696D6174696F6E4475726174696F6E3D6E756C6C7D2929293A722E5F73686F77436C6F6E65286E2929297D2C647261674F766572416E696D6174696F6E436170747572653A66756E6374696F6E2874297B76617220653D742E6472616752656374';
wwv_flow_imp.g_varchar2_table(420) := '2C6F3D742E69734F776E65723B743D742E616374697665536F727461626C653B75652E666F7245616368282866756E6374696F6E2874297B742E74686973416E696D6174696F6E4475726174696F6E3D6E756C6C7D29292C742E6F7074696F6E732E616E';
wwv_flow_imp.g_varchar2_table(421) := '696D6174696F6E2626216F2626742E6D756C7469447261672E69734D756C74694472616726262873653D6E287B7D2C65292C653D5F286C652C2130292C73652E746F702D3D652E662C73652E6C6566742D3D652E65297D2C647261674F766572416E696D';
wwv_flow_imp.g_varchar2_table(422) := '6174696F6E436F6D706C6574653A66756E6374696F6E28297B706526262870653D21312C6D652829297D2C64726F703A66756E6374696F6E2874297B76617220652C6E2C6F2C692C722C612C6C2C733D742E6F726967696E616C4576656E742C633D742E';
wwv_flow_imp.g_varchar2_table(423) := '726F6F74456C2C753D742E706172656E74456C2C643D742E736F727461626C652C683D742E6469737061746368536F727461626C654576656E742C703D742E6F6C64496E6465782C663D28743D742E707574536F727461626C65297C7C746869732E736F';
wwv_flow_imp.g_varchar2_table(424) := '727461626C653B73262628653D746869732E6F7074696F6E732C6E3D752E6368696C6472656E2C66657C7C28652E6D756C7469447261674B6579262621746869732E6D756C7469447261674B6579446F776E2626746869732E5F646573656C6563744D75';
wwv_flow_imp.g_varchar2_table(425) := '6C74694472616728292C45286C652C652E73656C6563746564436C6173732C217E75652E696E6465784F66286C6529292C7E75652E696E6465784F66286C65293F2875652E73706C6963652875652E696E6465784F66286C65292C31292C72653D6E756C';
wwv_flow_imp.g_varchar2_table(426) := '6C2C7A287B736F727461626C653A642C726F6F74456C3A632C6E616D653A22646573656C656374222C746172676574456C3A6C652C6F726967696E616C4576656E743A737D29293A2875652E70757368286C65292C7A287B736F727461626C653A642C72';
wwv_flow_imp.g_varchar2_table(427) := '6F6F74456C3A632C6E616D653A2273656C656374222C746172676574456C3A6C652C6F726967696E616C4576656E743A737D292C732E73686966744B6579262672652626642E656C2E636F6E7461696E73287265293F286F3D4E287265292C693D4E286C';
wwv_flow_imp.g_varchar2_table(428) := '65292C7E6F26267E6926266F213D3D69262666756E6374696F6E28297B666F722876617220742C723D6F3C693F28743D6F2C69293A28743D692C6F2B31292C613D652E66696C7465723B743C723B742B2B297E75652E696E6465784F66286E5B745D297C';
wwv_flow_imp.g_varchar2_table(429) := '7C79286E5B745D2C652E647261676761626C652C752C213129262628612626282266756E6374696F6E223D3D747970656F6620613F612E63616C6C28642C732C6E5B745D2C64293A612E73706C697428222C22292E736F6D65282866756E6374696F6E28';
wwv_flow_imp.g_varchar2_table(430) := '65297B72657475726E2079286E5B745D2C652E7472696D28292C752C2131297D2929297C7C2845286E5B745D2C652E73656C6563746564436C6173732C2130292C75652E70757368286E5B745D292C7A287B736F727461626C653A642C726F6F74456C3A';
wwv_flow_imp.g_varchar2_table(431) := '632C6E616D653A2273656C656374222C746172676574456C3A6E5B745D2C6F726967696E616C4576656E743A737D2929297D2829293A72653D6C652C61653D6629292C66652626746869732E69734D756C74694472616726262870653D21312C28755B48';
wwv_flow_imp.g_varchar2_table(432) := '5D2E6F7074696F6E732E736F72747C7C75213D3D63292626313C75652E6C656E677468262628723D78286C65292C613D4E286C652C223A6E6F74282E222B746869732E6F7074696F6E732E73656C6563746564436C6173732B222922292C216865262665';
wwv_flow_imp.g_varchar2_table(433) := '2E616E696D6174696F6E2626286C652E74686973416E696D6174696F6E4475726174696F6E3D6E756C6C292C662E63617074757265416E696D6174696F6E537461746528292C68657C7C28652E616E696D6174696F6E2626286C652E66726F6D52656374';
wwv_flow_imp.g_varchar2_table(434) := '3D722C75652E666F7245616368282866756E6374696F6E2874297B76617220653B742E74686973416E696D6174696F6E4475726174696F6E3D6E756C6C2C74213D3D6C65262628653D70653F782874293A722C742E66726F6D526563743D652C662E6164';
wwv_flow_imp.g_varchar2_table(435) := '64416E696D6174696F6E5374617465287B7461726765743A742C726563743A657D29297D2929292C6D6528292C75652E666F7245616368282866756E6374696F6E2874297B6E5B615D3F752E696E736572744265666F726528742C6E5B615D293A752E61';
wwv_flow_imp.g_varchar2_table(436) := '7070656E644368696C642874292C612B2B7D29292C703D3D3D4E286C65292626286C3D21312C75652E666F7245616368282866756E6374696F6E2874297B742E736F727461626C65496E646578213D3D4E2874292626286C3D2130297D29292C6C262628';
wwv_flow_imp.g_varchar2_table(437) := '68282275706461746522292C682822736F727422292929292C75652E666F7245616368282866756E6374696F6E2874297B462874297D29292C662E616E696D617465416C6C2829292C61653D66292C28633D3D3D757C7C74262622636C6F6E6522213D3D';
wwv_flow_imp.g_varchar2_table(438) := '742E6C6173745075744D6F646529262664652E666F7245616368282866756E6374696F6E2874297B742E706172656E744E6F64652626742E706172656E744E6F64652E72656D6F76654368696C642874297D2929297D2C6E756C6C696E67476C6F62616C';
wwv_flow_imp.g_varchar2_table(439) := '3A66756E6374696F6E28297B746869732E69734D756C7469447261673D66653D21312C64652E6C656E6774683D307D2C64657374726F79476C6F62616C3A66756E6374696F6E28297B746869732E5F646573656C6563744D756C74694472616728292C6D';
wwv_flow_imp.g_varchar2_table(440) := '28646F63756D656E742C22706F696E7465727570222C746869732E5F646573656C6563744D756C746944726167292C6D28646F63756D656E742C226D6F7573657570222C746869732E5F646573656C6563744D756C746944726167292C6D28646F63756D';
wwv_flow_imp.g_varchar2_table(441) := '656E742C22746F756368656E64222C746869732E5F646573656C6563744D756C746944726167292C6D28646F63756D656E742C226B6579646F776E222C746869732E5F636865636B4B6579446F776E292C6D28646F63756D656E742C226B65797570222C';
wwv_flow_imp.g_varchar2_table(442) := '746869732E5F636865636B4B65795570297D2C5F646573656C6563744D756C7469447261673A66756E6374696F6E2874297B6966282128766F69642030213D3D6665262666657C7C6165213D3D746869732E736F727461626C657C7C7426267928742E74';
wwv_flow_imp.g_varchar2_table(443) := '61726765742C746869732E6F7074696F6E732E647261676761626C652C746869732E736F727461626C652E656C2C2131297C7C74262630213D3D742E627574746F6E2929666F72283B75652E6C656E6774683B297B76617220653D75655B305D3B452865';
wwv_flow_imp.g_varchar2_table(444) := '2C746869732E6F7074696F6E732E73656C6563746564436C6173732C2131292C75652E736869667428292C7A287B736F727461626C653A746869732E736F727461626C652C726F6F74456C3A746869732E736F727461626C652E656C2C6E616D653A2264';
wwv_flow_imp.g_varchar2_table(445) := '6573656C656374222C746172676574456C3A652C6F726967696E616C4576656E743A747D297D7D2C5F636865636B4B6579446F776E3A66756E6374696F6E2874297B742E6B65793D3D3D746869732E6F7074696F6E732E6D756C7469447261674B657926';
wwv_flow_imp.g_varchar2_table(446) := '2628746869732E6D756C7469447261674B6579446F776E3D2130297D2C5F636865636B4B657955703A66756E6374696F6E2874297B742E6B65793D3D3D746869732E6F7074696F6E732E6D756C7469447261674B6579262628746869732E6D756C746944';
wwv_flow_imp.g_varchar2_table(447) := '7261674B6579446F776E3D2131297D7D2C6E28742C7B706C7567696E4E616D653A226D756C746944726167222C7574696C733A7B73656C6563743A66756E6374696F6E2874297B76617220653D742E706172656E744E6F64655B485D3B652626652E6F70';
wwv_flow_imp.g_varchar2_table(448) := '74696F6E732E6D756C7469447261672626217E75652E696E6465784F66287429262628616526266165213D3D6526262861652E6D756C7469447261672E5F646573656C6563744D756C74694472616728292C61653D65292C4528742C652E6F7074696F6E';
wwv_flow_imp.g_varchar2_table(449) := '732E73656C6563746564436C6173732C2130292C75652E70757368287429297D2C646573656C6563743A66756E6374696F6E2874297B76617220653D742E706172656E744E6F64655B485D2C6E3D75652E696E6465784F662874293B652626652E6F7074';
wwv_flow_imp.g_varchar2_table(450) := '696F6E732E6D756C74694472616726267E6E2626284528742C652E6F7074696F6E732E73656C6563746564436C6173732C2131292C75652E73706C696365286E2C3129297D7D2C6576656E7450726F706572746965733A66756E6374696F6E28297B7661';
wwv_flow_imp.g_varchar2_table(451) := '7220743D746869732C653D5B5D2C6E3D5B5D3B72657475726E2075652E666F7245616368282866756E6374696F6E286F297B76617220693B652E70757368287B6D756C746944726167456C656D656E743A6F2C696E6465783A6F2E736F727461626C6549';
wwv_flow_imp.g_varchar2_table(452) := '6E6465787D292C693D706526266F213D3D6C653F2D313A70653F4E286F2C223A6E6F74282E222B742E6F7074696F6E732E73656C6563746564436C6173732B222922293A4E286F292C6E2E70757368287B6D756C746944726167456C656D656E743A6F2C';
wwv_flow_imp.g_varchar2_table(453) := '696E6465783A697D297D29292C7B6974656D733A72287565292C636C6F6E65733A5B5D2E636F6E636174286465292C6F6C64496E6469636965733A652C6E6577496E6469636965733A6E7D7D2C6F7074696F6E4C697374656E6572733A7B6D756C746944';
wwv_flow_imp.g_varchar2_table(454) := '7261674B65793A66756E6374696F6E2874297B72657475726E226374726C223D3D3D28743D742E746F4C6F776572436173652829293F743D22436F6E74726F6C223A313C742E6C656E677468262628743D742E6368617241742830292E746F5570706572';
wwv_flow_imp.g_varchar2_table(455) := '4361736528292B742E737562737472283129292C747D7D7D297D292C46747D29293B';
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(735124932171073118)
,p_plugin_id=>wwv_flow_imp.id(732552980942701141)
,p_file_name=>'sortablejs.min.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '617065782E64746C5F696E7075743D7B696E69743A66756E6374696F6E28652C74297B766172206E3D617065782E64796E616D6963436F72653B6E2E64656275673D2259223D3D3D742E6A734C6F67456E61626C65642C6E2E6C6F672822494E4954222C';
wwv_flow_imp.g_varchar2_table(2) := '652C74293B76617220723D646F63756D656E742E676574456C656D656E744279496428652B225F636F6E7461696E657222292C613D646F63756D656E742E676574456C656D656E74427949642865293B69662872262661297B766172206F3D742E6D6178';
wwv_flow_imp.g_varchar2_table(3) := '4974656D737C7C3939392C693D742E696E697469616C436F756E747C7C312C6C3D742E62746E735F706F737C7C2245222C643D742E62746E735F7374796C657C7C2244222C633D742E6D5F747970657C7C2244222C733D742E736570617261746F727C7C';
wwv_flow_imp.g_varchar2_table(4) := '223A222C753D742E76616C69646174696F6E547970657C7C224E222C663D742E72656765782C703D2259223D3D3D742E616C6C6F774475706C6963617465733B2166756E6374696F6E28297B7472797B76617220653D5B5D3B696628612E76616C756526';
wwv_flow_imp.g_varchar2_table(5) := '2628653D224A223D3D3D633F6E2E736166654A534F4E28612E76616C75652C5B5D293A612E76616C75652E73706C6974287329292C652E6C656E6774683E3029652E666F7245616368282866756E6374696F6E2865297B722E617070656E644368696C64';
wwv_flow_imp.g_varchar2_table(6) := '286D286529297D29293B656C736520666F722876617220743D303B743C693B742B2B29722E617070656E644368696C64286D28222229293B6728292C6E2E6C6F672822496E697469616C697A6564222C65297D63617463682865297B6E2E6572726F7228';
wwv_flow_imp.g_varchar2_table(7) := '22496E6974206572726F72222C65297D7D28297D656C7365206E2E6572726F722822436F6E7461696E65722F48696464656E206E6F7420666F756E64222C65293B66756E6374696F6E20762865297B72657475726E206E2E76616C696461746556616C75';
wwv_flow_imp.g_varchar2_table(8) := '6528652C752C66297D66756E6374696F6E206D2874297B76617220693D646F63756D656E742E637265617465456C656D656E74282264697622293B692E636C6173734E616D653D2264746C2D726F7720742D466F726D2D696E707574436F6E7461696E65';
wwv_flow_imp.g_varchar2_table(9) := '72223B76617220633D646F63756D656E742E637265617465456C656D656E742822696E70757422293B632E747970653D2274657874222C632E636C6173734E616D653D22746578745F6669656C6420617065782D6974656D2D74657874222C632E76616C';
wwv_flow_imp.g_varchar2_table(10) := '75653D747C7C22222C632E73697A653D223330223B76617220733D646F63756D656E742E637265617465456C656D656E742822627574746F6E22293B732E747970653D22627574746F6E222C732E636C6173734E616D653D2244223D3D3D643F22742D42';
wwv_flow_imp.g_varchar2_table(11) := '7574746F6E20742D427574746F6E2D2D6E6F554920742D427574746F6E2D2D69636F6E2064746C2D72656D6F7665223A22742D427574746F6E20742D427574746F6E2D2D69636F6E2064746C2D72656D6F766520742D427574746F6E2D2D64616E676572';
wwv_flow_imp.g_varchar2_table(12) := '222C732E696E6E657248544D4C3D273C7370616E20636C6173733D2266612066612D74696D6573223E3C2F7370616E3E272C732E6F6E636C69636B3D66756E6374696F6E28297B7472797B692E72656D6F766528292C6728292C6E2E7472696767657245';
wwv_flow_imp.g_varchar2_table(13) := '76656E7428612C22726F775F64656C65746564222C7B636F756E743A722E6368696C6472656E2E6C656E6774682C6974656D3A657D292C6E2E6C6F672822526F772064656C6574656422297D63617463682865297B6E2E6572726F72282252656D6F7665';
wwv_flow_imp.g_varchar2_table(14) := '206572726F72222C65297D7D3B76617220753D646F63756D656E742E637265617465456C656D656E742822627574746F6E22293B72657475726E20752E747970653D22627574746F6E222C752E636C6173734E616D653D2244223D3D3D643F22742D4275';
wwv_flow_imp.g_varchar2_table(15) := '74746F6E20742D427574746F6E2D2D6E6F554920742D427574746F6E2D2D69636F6E2064746C2D616464223A22742D427574746F6E20742D427574746F6E2D2D69636F6E2064746C2D61646420742D427574746F6E2D2D7072696D617279222C752E696E';
wwv_flow_imp.g_varchar2_table(16) := '6E657248544D4C3D273C7370616E20636C6173733D2266612066612D706C7573223E3C2F7370616E3E272C752E6F6E636C69636B3D66756E6374696F6E28297B7472797B696628722E6368696C6472656E2E6C656E6774683E3D6F2972657475726E206E';
wwv_flow_imp.g_varchar2_table(17) := '2E747269676765724576656E7428612C226D61785F726F77735F72656163686564222C7B6D61783A6F7D292C766F6964206E2E6C6F6728224D617820726F7773207265616368656422293B696628217628632E76616C7565292972657475726E20632E63';
wwv_flow_imp.g_varchar2_table(18) := '6C6173734C6973742E616464282264746C2D6572726F7222292C766F6964206E2E747269676765724576656E7428612C2276616C69646174696F6E5F6661696C6564222C7B76616C75653A632E76616C75652C6974656D3A657D293B632E636C6173734C';
wwv_flow_imp.g_varchar2_table(19) := '6973742E72656D6F7665282264746C2D6572726F7222293B76617220743D6D282222293B722E617070656E644368696C642874292C6728292C6E2E747269676765724576656E7428612C22726F775F6164646564222C7B636F756E743A722E6368696C64';
wwv_flow_imp.g_varchar2_table(20) := '72656E2E6C656E6774682C6974656D3A657D292C742E717565727953656C6563746F722822696E70757422292E666F63757328297D63617463682865297B6E2E6572726F722822416464206572726F72222C65297D7D2C2253223D3D3D6C3F28692E6170';
wwv_flow_imp.g_varchar2_table(21) := '70656E644368696C642873292C692E617070656E644368696C642875292C692E617070656E644368696C64286329293A28692E617070656E644368696C642863292C692E617070656E644368696C642873292C692E617070656E644368696C6428752929';
wwv_flow_imp.g_varchar2_table(22) := '2C632E6164644576656E744C697374656E65722822696E707574222C6E2E6465626F756E636528672C33303029292C632E6164644576656E744C697374656E657228226B6579646F776E222C2866756E6374696F6E2865297B22456E746572223D3D3D65';
wwv_flow_imp.g_varchar2_table(23) := '2E6B6579262628652E70726576656E7444656661756C7428292C752E636C69636B2829297D29292C697D66756E6374696F6E206728297B7472797B76617220743D722E717565727953656C6563746F72416C6C28222E64746C2D726F7722292C693D5B5D';
wwv_flow_imp.g_varchar2_table(24) := '2C6C3D6E6577205365742C643D21313B742E666F7245616368282866756E6374696F6E2865297B76617220743D652E717565727953656C6563746F722822696E70757422292C6E3D742E76616C75652E7472696D28293B76286E293F742E636C6173734C';
wwv_flow_imp.g_varchar2_table(25) := '6973742E72656D6F7665282264746C2D6572726F7222293A742E636C6173734C6973742E616464282264746C2D6572726F7222292C217026262222213D3D6E26266C2E686173286E293F28652E636C6173734C6973742E616464282264746C2D6475706C';
wwv_flow_imp.g_varchar2_table(26) := '696361746522292C643D2130293A652E636C6173734C6973742E72656D6F7665282264746C2D6475706C696361746522292C2222213D3D6E2626692E70757368286E292C6C2E616464286E297D29293B76617220753D224A223D3D3D633F4A534F4E2E73';
wwv_flow_imp.g_varchar2_table(27) := '7472696E676966792869293A692E6A6F696E2873293B617065782E6974656D2865292E73657456616C75652875292C742E666F7245616368282866756E6374696F6E28652C6E297B76617220723D652E717565727953656C6563746F7228222E64746C2D';
wwv_flow_imp.g_varchar2_table(28) := '72656D6F766522292C613D652E717565727953656C6563746F7228222E64746C2D61646422293B722E7374796C652E646973706C61793D313D3D3D742E6C656E6774683F226E6F6E65223A22696E6C696E652D626C6F636B222C612E7374796C652E6469';
wwv_flow_imp.g_varchar2_table(29) := '73706C61793D6E3D3D3D742E6C656E6774682D312626742E6C656E6774683C6F3F22696E6C696E652D626C6F636B223A226E6F6E65227D29292C6E2E747269676765724576656E7428612C2276616C75655F6368616E676564222C7B76616C7565733A69';
wwv_flow_imp.g_varchar2_table(30) := '2C6974656D3A657D292C6426266E2E747269676765724576656E7428612C226475706C6963617465735F666F756E64222C7B6974656D3A657D292C6E2E6C6F6728225265667265736820636F6D706C657465222C69297D63617463682865297B6E2E6572';
wwv_flow_imp.g_varchar2_table(31) := '726F72282252656672657368206572726F72222C65297D7D7D7D2C617065782E64746C5F72656F726465723D7B696E69743A66756E6374696F6E28652C74297B766172206E3D617065782E64796E616D6963436F72653B6E2E64656275673D2259223D3D';
wwv_flow_imp.g_varchar2_table(32) := '3D742E6A734C6F67456E61626C65642C6E2E6C6F672822494E4954222C652C74293B76617220723D646F63756D656E742E676574456C656D656E744279496428652B225F636F6E7461696E657222292C613D646F63756D656E742E676574456C656D656E';
wwv_flow_imp.g_varchar2_table(33) := '74427949642865293B69662872262661297B612E5F64746C5F6F7074696F6E733D743B766172206F3D6E756C6C3B2166756E6374696F6E28297B7472797B76617220653D6E2E736166654A534F4E28742E736F75726365446174612C5B5D293B65262630';
wwv_flow_imp.g_varchar2_table(34) := '213D3D652E6C656E6774687C7C21612E76616C75657C7C28653D6E2E736166654A534F4E28612E76616C75652C5B5D29292C632865297D63617463682865297B6E2E6572726F722822696E6974526F7773206661696C6564222C65292C6928297D7D2829';
wwv_flow_imp.g_varchar2_table(35) := '2C66756E6374696F6E28297B69662822756E646566696E656422213D747970656F6620536F727461626C65297B696628216F297472797B6F3D6E657720536F727461626C6528722C7B616E696D6174696F6E3A3135302C68616E646C653A222E64746C2D';
wwv_flow_imp.g_varchar2_table(36) := '68616E646C65222C67686F7374436C6173733A2264746C2D647261672D67686F7374222C6F6E456E643A66756E6374696F6E28297B76617220743D6C28293B642874292C6E2E747269676765724576656E7428612C22726F775F72656F72646572656422';
wwv_flow_imp.g_varchar2_table(37) := '2C7B76616C7565733A742C6974656D3A657D297D7D297D63617463682865297B6E2E6572726F722822536F727461626C6520696E6974206661696C6564222C65297D7D656C7365206E2E6572726F722822536F727461626C654A53206E6F74206C6F6164';
wwv_flow_imp.g_varchar2_table(38) := '656422297D28292C612E5F64746C5F726566726573683D66756E6374696F6E28297B696628742E616A61784964656E746966696572297B766172206F3B6E2E6C6F672822414A41582043414C4C222C74293B7472797B6F3D617065782E7574696C2E7368';
wwv_flow_imp.g_varchar2_table(39) := '6F775370696E6E65722872292C722E7374796C652E706F696E7465724576656E74733D226E6F6E65222C722E7374796C652E6F7061636974793D22302E35227D63617463682865297B6E2E6572726F7228225370696E6E6572206661696C6564222C6529';
wwv_flow_imp.g_varchar2_table(40) := '7D617065782E7365727665722E706C7567696E28742E616A61784964656E7469666965722C7B706167654974656D733A28742E706167654974656D737C7C2222292E73706C697428222C22292E6D6170282866756E6374696F6E2865297B72657475726E';
wwv_flow_imp.g_varchar2_table(41) := '2223222B652E7472696D28297D29292E6A6F696E28222C22297D2C7B737563636573733A66756E6374696F6E2874297B6E2E6C6F672822414A41582053554343455353222C74293B7472797B76617220723D6E2E736166654A534F4E28742E646174612C';
wwv_flow_imp.g_varchar2_table(42) := '5B5D293B632872292C6E2E747269676765724576656E7428612C22646174615F726566726573686564222C7B636F756E743A722E6C656E6774682C6974656D3A657D297D63617463682865297B6E2E6572726F722822414A415820737563636573732070';
wwv_flow_imp.g_varchar2_table(43) := '726F63657373696E67206661696C6564222C65292C692822496E76616C6964206461746122297D6C28297D2C6572726F723A66756E6374696F6E2865297B6E2E6572726F722822414A4158204552524F52222C65292C6928224661696C656420746F206C';
wwv_flow_imp.g_varchar2_table(44) := '6F6164206461746122292C6C28297D7D297D656C7365206E2E6C6F6728224E6F20414A4158206964656E7469666965722C20736B697070696E67207265667265736822293B66756E6374696F6E206C28297B7472797B6F26266F2E72656D6F766528292C';
wwv_flow_imp.g_varchar2_table(45) := '722E7374796C652E706F696E7465724576656E74733D226175746F222C722E7374796C652E6F7061636974793D2231227D63617463682865297B6E2E6572726F722822436C65616E7570206661696C6564222C65297D7D7D7D656C7365206E2E6572726F';
wwv_flow_imp.g_varchar2_table(46) := '722822436F6E7461696E6572206F722068696464656E206E6F7420666F756E64222C65293B66756E6374696F6E20692865297B722E696E6E657248544D4C3D605C6E202020202020202020202020202020203C64697620636C6173733D22742D416C6572';
wwv_flow_imp.g_varchar2_table(47) := '7420742D416C6572742D2D64616E676572223E5C6E2020202020202020202020202020202020202020247B657C7C224572726F72206C6F6164696E672064617461227D5C6E202020202020202020202020202020203C2F6469763E5C6E20202020202020';
wwv_flow_imp.g_varchar2_table(48) := '2020202020607D66756E6374696F6E206C28297B7472797B76617220653D722E717565727953656C6563746F72416C6C28222E64746C2D726F7722292C743D5B5D3B72657475726E20652E666F7245616368282866756E6374696F6E2865297B742E7075';
wwv_flow_imp.g_varchar2_table(49) := '7368287B69643A652E646174617365742E69642C6C6162656C3A652E717565727953656C6563746F722822696E70757422292E76616C75657D297D29292C747D63617463682865297B72657475726E206E2E6572726F72282267657456616C7565732066';
wwv_flow_imp.g_varchar2_table(50) := '61696C6564222C65292C5B5D7D7D66756E6374696F6E20642874297B7472797B617065782E6974656D2865292E73657456616C7565284A534F4E2E737472696E67696679287429297D63617463682865297B6E2E6572726F72282273657456616C756520';
wwv_flow_imp.g_varchar2_table(51) := '6661696C6564222C65297D7D66756E6374696F6E20632865297B6966286E2E6C6F67282252656E646572206C697374222C65292C722E696E6E657248544D4C3D22222C21657C7C303D3D3D652E6C656E6774682972657475726E20613D646F63756D656E';
wwv_flow_imp.g_varchar2_table(52) := '742E637265617465456C656D656E74282264697622292C6F3D742E6E6F44617461466F756E647C7C224E6F206461746120666F756E64222C612E636C6173734E616D653D22742D416C65727420742D416C6572742D2D64656661756C7449636F6E732074';
wwv_flow_imp.g_varchar2_table(53) := '2D416C6572742D2D7761726E696E6720742D416C6572742D2D686F72697A6F6E74616C222C612E696E6E657248544D4C3D605C6E202020202020202020202020202020203C64697620636C6173733D22742D416C6572742D77726170223E5C6E20202020';
wwv_flow_imp.g_varchar2_table(54) := '202020202020202020202020202020203C64697620636C6173733D22742D416C6572742D69636F6E223E5C6E2020202020202020202020202020202020202020202020203C7370616E20636C6173733D22742D49636F6E2066612D696E666F2D63697263';
wwv_flow_imp.g_varchar2_table(55) := '6C65223E3C2F7370616E3E5C6E20202020202020202020202020202020202020203C2F6469763E5C6E20202020202020202020202020202020202020203C64697620636C6173733D22742D416C6572742D636F6E74656E74223E5C6E2020202020202020';
wwv_flow_imp.g_varchar2_table(56) := '202020202020202020202020202020203C64697620636C6173733D22742D416C6572742D626F6479223E5C6E20202020202020202020202020202020202020202020202020202020247B6F7D5C6E20202020202020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(57) := '20203C2F6469763E5C6E20202020202020202020202020202020202020203C2F6469763E5C6E202020202020202020202020202020203C2F6469763E5C6E202020202020202020202020602C722E617070656E644368696C642861292C766F6964206428';
wwv_flow_imp.g_varchar2_table(58) := '5B5D293B76617220612C6F3B7472797B652E666F7245616368282866756E6374696F6E2865297B722E617070656E644368696C642866756E6374696F6E2865297B7472797B76617220743D646F63756D656E742E637265617465456C656D656E74282264';
wwv_flow_imp.g_varchar2_table(59) := '697622293B742E636C6173734E616D653D2264746C2D726F7720742D466F726D2D696E707574436F6E7461696E6572222C742E646174617365742E69643D652E69643B76617220723D646F63756D656E742E637265617465456C656D656E742822737061';
wwv_flow_imp.g_varchar2_table(60) := '6E22293B722E636C6173734E616D653D2266612066612D626172732064746C2D68616E646C65223B76617220613D646F63756D656E742E637265617465456C656D656E742822696E70757422293B72657475726E20612E747970653D2274657874222C61';
wwv_flow_imp.g_varchar2_table(61) := '2E636C6173734E616D653D22746578745F6669656C6420617065782D6974656D2D74657874222C612E76616C75653D652E6C6162656C7C7C22222C612E726561644F6E6C793D21302C742E617070656E644368696C642872292C742E617070656E644368';
wwv_flow_imp.g_varchar2_table(62) := '696C642861292C747D63617463682874297B72657475726E206E2E6572726F722822637265617465526F77206661696C6564222C742C65292C646F63756D656E742E637265617465456C656D656E74282264697622297D7D286529297D29292C64286C28';
wwv_flow_imp.g_varchar2_table(63) := '29297D63617463682865297B6E2E6572726F72282272656E6465724C697374206661696C6564222C65292C6928297D7D7D2C726566726573683A66756E6374696F6E2865297B76617220743D646F63756D656E742E676574456C656D656E744279496428';
wwv_flow_imp.g_varchar2_table(64) := '65293B742626742E5F64746C5F726566726573683F742E5F64746C5F7265667265736828293A636F6E736F6C652E7761726E282244544C3A2072656672657368206E6F7420696E697469616C697A6564222C65297D7D2C617065782E64796E616D696343';
wwv_flow_imp.g_varchar2_table(65) := '6F72653D7B64656275673A21302C6C6F673A66756E6374696F6E28297B746869732E64656275672626636F6E736F6C652E6C6F672E6170706C7928636F6E736F6C652C5B2244544C3A225D2E636F6E6361742841727261792E66726F6D28617267756D65';
wwv_flow_imp.g_varchar2_table(66) := '6E74732929297D2C6572726F723A66756E6374696F6E28297B636F6E736F6C652E6572726F722E6170706C7928636F6E736F6C652C5B2244544C204552524F523A225D2E636F6E6361742841727261792E66726F6D28617267756D656E74732929297D2C';
wwv_flow_imp.g_varchar2_table(67) := '6465626F756E63653A66756E6374696F6E28652C74297B6C6574206E3B72657475726E2066756E6374696F6E28297B636C65617254696D656F7574286E292C6E3D73657454696D656F757428652C74297D7D2C747269676765724576656E743A66756E63';
wwv_flow_imp.g_varchar2_table(68) := '74696F6E28652C742C6E297B7472797B617065782E6576656E742E7472696767657228652C742C6E7C7C7B7D297D63617463682865297B746869732E6572726F7228224576656E742074726967676572206661696C6564222C742C65297D7D2C73616665';
wwv_flow_imp.g_varchar2_table(69) := '4A534F4E3A66756E6374696F6E28652C74297B7472797B72657475726E22737472696E67223D3D747970656F6620653F4A534F4E2E70617273652865293A657D6361746368286E297B72657475726E20746869732E6572726F7228224A534F4E20706172';
wwv_flow_imp.g_varchar2_table(70) := '7365206661696C6564222C652C6E292C747C7C5B5D7D7D2C76616C696461746556616C75653A66756E6374696F6E28652C742C6E297B72657475726E2245223D3D3D743F2F5E5B5E5C73405D2B405B5E5C73405D2B5C2E5B5E5C73405D2B242F2E746573';
wwv_flow_imp.g_varchar2_table(71) := '742865293A2250223D3D3D743F2F5E5B302D392B5C2D5C735D2B242F2E746573742865293A225222213D3D747C7C6E657720526567457870286E292E746573742865297D7D3B';
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(737082904456119679)
,p_plugin_id=>wwv_flow_imp.id(732552980942701141)
,p_file_name=>'pjs.min.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
prompt --application/end_environment
begin
wwv_flow_imp.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false)
);
commit;
end;
/
set verify on feedback on define on
prompt  ...done
