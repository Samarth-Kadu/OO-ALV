REPORT ZPRG_OOALV.

TABLES: vbak.
TABLES: VBAP.

SELECT-OPTIONS: s_ono for vbak-vbeln.

TYPES: BEGIN OF str1,
  vbeln type  vbeln,
  erdat TYPE erdat,
  erzet TYPE erzet,
  ernam TYPE ernam,
  vbtyp TYPE vbtyp,
  end of str1.

  data : it_vbak type  table of str1 with header line.
  data : wa_vbak type str1.

TYPES: BEGIN OF str2,
  vbeln TYPE vbeln,
  posnr TYPE posnr,
  matnr TYPE matnr,
  end of str2.

  data : it_vbap type table  of str2 with header line.
  data : WA_VBAP TYPE STR2.

TYPES: BEGIN OF STR3,
   VBELN TYPE VBLEN,
  ERDAT TYPE ERDAT,
  ERZET TYPE  ERZET,
  ERNAM TYPE ERNAM,
  VBTYP TYPE VBTYP,
  POSNR TYPE POSNR,
  MATNR TYPE MATNR,
  END OF STR3.

  DATA IT_FINAL TYPE TABLE OF STR3 with header line.
  DATA WA_FINAL TYPE STR3.


SELECT VBELN ERDAT ERZET ERNAM VBTYP
FROM VBAK
INTO TABLE IT_VBAK
WHERE VBELN = S_ONO.

IF IT_VBAK  IS NOT INITIAL.
  SELECT VBELN POSNR MATNR
  FROM VBAP
  INTO TABLE IT_VBAP
  FOR ALL ENTRIES IN IT_VBAK
  WHERE VBELN = IT_VBAK-VBELN.
ENDIF.

 LOOP AT it_vbak FROM WA_VBAK.
 LOOP AT IT_VBAP FROM WA_VBAP WHERE VBELN = WA_VBAK-VBELN.
   WA_FINAL-VBELN = WA_VBAK-VBELN.
   WA_FINAL-ERDAT = WA_VBAK-ERDAT.
   WA_FINAL-ERZET = WA_VBAK-ERZET.
   WA_FINAL-ERNAM = WA_VBAK-ERNAM.
   WA_FINAL-VBTYP = WA_VBAK-VBTYP.
   WA_FINAL-POSNR = WA_VBAP-POSNR.
   WA_FINAL-MATNR = WA_VBAP-MATNR.
 APPEND WA_FINAL TO IT_FINAL.
 CLEAR : WA_FINAL.
 endloop.
 endloop.

 WRITE: IT_FINAL-VBELN, IT_FINAL-ERDAT, IT_FINAL-ERZET, IT_FINAL-ERNAM, IT_FINAL-VBTYP, IT_FINAL-POSNR, IT_FINAL-MATNR.

 DATA: lt_fieldcat type LVC_T_FCAT.
 data: lo_object type  ref to  cl_gui_custom_container.
 DATA: LO_GRID TYPE CL_GUI_CUSTOM_GRID.

CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
 EXPORTING
*   I_BUFFER_ACTIVE              =
   I_STRUCTURE_NAME             =  'ZSTR_OO_ALV'
*   I_CLIENT_NEVER_DISPLAY       = 'X'
*   I_BYPASSING_BUFFER           =
*   I_INTERNAL_TABNAME           =
  CHANGING
    CT_FIELDCAT                  = lt_fieldcat
 EXCEPTIONS
   INCONSISTENT_INTERFACE       = 1
   PROGRAM_ERROR                = 2
   OTHERS                       = 3
          .
IF SY-SUBRC <> 0.
* Implement suitable error handling here
ENDIF.

create object lo_object
EXPORTING
CONTAINER_NAME = 'CONT'.

CREATE OBJECT LO_GRID
EXPORTING
PARENT = LO_OBJECT.

CALL METHOD LO_GRID->SET_TABLE_FOR_FIRST_DISPLAY
CHANGING
    IT_OUTTAB                     = IT_FINAL
    IT_FIELDCATALOG               = LT_fieldcat
*    IT_SORT                       =
*    IT_FILTER                     =
  EXCEPTIONS
    INVALID_PARAMETER_COMBINATION = 1
    PROGRAM_ERROR                 = 2
    TOO_MANY_LINES                = 3
    others                        = 4
        .
IF SY-SUBRC <> 0.
* Implement suitable error handling here
ENDIF.

call screen '100'.