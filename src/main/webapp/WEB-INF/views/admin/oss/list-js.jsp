<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ include file="/WEB-INF/constants.jsp"%>
<script type="text/javascript">
	/*global $ */
	/*jslint browser: true, nomen: true */
	
	var groupBuffer='';
	var initYn = true;
	var totalRow = 0;
	const G_ROW_CNT = "${ct:getCodeExpString(ct:getConstDef('CD_EXCEL_DOWNLOAD'), ct:getConstDef('CD_MAX_ROW_COUNT'))}";
	
	$(document).ready(function () {
		'use strict';
		setMaxRowCnt(G_ROW_CNT); // maxRowCnt 값 setting
		evt.init();
		data.init();
		initYn = false;
		
		showHelpLink("OSS_List_Main");
	});
	
	//데이터 객체
	var data = {
		typeCodes : [],
		tooltipCont : "<div class=\"tooltipData\"><dl><dt><span class=\"iconSet ops\">Notice Obligation</span>Notice Obligation</dt><dd></dd></dl><dl><dt><span class=\"iconSet man\">Source Code Obligation</span>Source Code Obligation</dt><dd></dd></dl></div>",
		tooltipCont2 : "<div class=\"tooltipData350\"><dl><dt><span class=\"iconSet multi\">Multi License</span>Multi License</dt><dd>The OSS contains source codes under multiple licenses.</dd><dd>본 OSS는 여러 License 하의 Source Code를 포함하고 있습니다.</dd><dd>(e.g. \lib is LGPL-2.1 <span style=\"text-decoration : underline;\">and</span> \src is GPL-2.0)</dd></dl><dl><dt><span class=\"iconSet dual\">Dual License</span>Dual License</dt><dd>You can select one of registered licenses.</dd><dd>본 OSS는 등록된 License 중 하나를 선택할 수 있습니다.</dd><dd>(e.g. GPL-2.0 <span style=\"text-decoration : underline;\">or</span> MIT)</dd></dl><dl><dt><span class=\"iconSet vdif\">Version Different License</span>Version Different License</dt><dd>The OSS is distributed under <span style=\"text-decoration : underline;\">different licenses</span> according to its <span style=\"text-decoration : underline;\">versions</span>.</dd><dd>본 OSS는 Version에 따라 다른 License로 배포되고 있습니다.</dd><dd>(e.g. v1.0 is under GPL-2.0 and v2.0 is under BSD-3-Clause)</dd></dl></div>",
		existTooltip : false,
		init : function(){
			list.load();	// Grid Load
		}
		
	};
	//이벤트 객체
	var evt = {
		init : function(){
			
			$('#search').on('click',function(e){
				e.preventDefault();
				
				var postData=$('#ossSearch').serializeObject();
				
				if(initYn) {
					list.load();
					initYn = false;
				} else {
					$("#list").jqGrid('setGridParam', {postData:postData, page : 1, url:'/oss/listAjax'}).trigger('reloadGrid');
				}
			});
			
			$('select[name=creator]').val('${searchBean.creator}').trigger('change');
			$('select[name=modifier]').val('${searchBean.modifier}').trigger('change');
			
			$(".cal").on("keyup", function(e){
				calValidation(this, e);
			});

			$("#ossNameAllSearchFlag").on("click", function(e){
				$("[name='ossNameAllSearchFlag']").val($(this).prop("checked") ? "Y" : "N");
			});

			$("#licenseNameAllSearchFlag").on("click", function(e){
				$("[name='licenseNameAllSearchFlag']").val($(this).prop("checked") ? "Y" : "N");
			});

			$("#deactivateFlag").on("click", function(){
				$("[name='deactivateFlag']").val($(this).prop("checked") ? "Y" : "N");
			});
		}
	};
	
	var fn = {
		showURL:function(){},
		hideURL:function(){},
		downloadExcel : function(){
			if(isMaximumRowCheck(totalRow)){
				var data = $('#ossSearch').serializeObject();
				
				if(data.copyrights == ''){
					data.copyrights = [];
				}
	
				$('input[name=parameter]').val(JSON.stringify(data));
			
				$("#ossSearch").ajaxForm({
		            url :'/exceldownload/getExcelPostOss',
		            type : 'POST',
		            dataType:"json",
		            cache : false,
			        success : function (data) {
						   if("false" == data.isValid) {
							   if(data.validMsg == "overflow") {
								   alertify.error(getMsgMaxRowCnt(), 0);
							   } else {
				                   alertify.error('<spring:message code="msg.common.valid2" />', 0);
							   }
						   } else {
						       window.location =  '<c:url value="/exceldownload/getFile?id='+data.validMsg+'"/>';
						   }
			        },
		            error : function(data){
						alertify.error('<spring:message code="msg.common.valid2" />', 0);
					}
			    }).submit();
			}
		},
		validationDate : function(){
			var flag = true;
			var cStart = $('input[name=cStartDate]').val().replace(/\./g,'');
			var cEnd = $('input[name=cEndDate]').val().replace(/\./g,'');
			var mStart = $('input[name=mStartDate]').val().replace(/\./g,'');
			var mEnd = $('input[name=mEndDate]').val().replace(/\./g,'');
			
			//둘다 비었을때
			if(!cStart && !cEnd) {
				
			} else {
				if(!cStart) {
					alert("시작 날짜를 확인해 주세요");
					flag = false;
				} else {
					alert("끝 날짜를 확인해 주세요");
					flag = false;
				}
			}
			
			if(flag) {
				if(!mStart && !mEnd) {
					
				} else {
					if(!mStart) {
						alert("시작 날짜를 확인해 주세요");
						flag = false;
					} else {
						alert("끝 날짜를 확인해 주세요");
						flag = false;
					}
				}
			}
			
			return flag;
		}
	}
	
	var list = {
		oldRowNum:20,
		load : function(){
			$("#list").jqGrid({
				datatype: 'json',
				jsonReader:{
					repeatitems: false,
					id:'ossId',
					root:function(obj){
						//기존의 RowNum 저장
						list.oldRowNum = $("#list").jqGrid('getGridParam', 'rowNum');
						
						//리스트 갯수에 따른 rowNum 변경@@1
						$("#list").jqGrid('setGridParam', {rowNum:obj.rows.length});
						$("#list").jqGrid('setGridParam', {defaultRowNum:list.oldRowNum});
						
						return obj.rows; 
					},
					page:function(obj){return obj.page;},
					total:function(obj){return obj.total;},
					records:function(obj){return obj.records;}
				},
				colNames: ['', 'ID','OSS Type','OSS Name','Version','License Name', 'License Type', 'Obligation', 'Download Location', 'Homepage', 'Description', 'CVE ID', 'Vulnera<br/>bility'<c:if test="${ct:isAdmin()}">, 'Creator', 'Created Date','Modifier','Modified Date'</c:if>, 'groupKey'],
				colModel: [
					  {name: 'group', width: 20, align: 'center',
					    cellattr: function(rowId, tv, rawObject, cm, rdata) {
					        return ' colspan=2' 
					    },
					    formatter: function myFormatter(cellvalue, options, rowObject){
					        return rowObject.ossId;
					    }
					  }
					, {name: 'ossId', index: 'ossId', width: 80, align: 'center',
					    cellattr: function(rowId, tv, rawObject, cm, rdata) {
					        return ' style="display:none;"';
					    }
					  }
					, {name: 'ossType', index: 'ossType', width: 70, align: 'center',formatter: 'ossType'}
					, {name: 'ossName', index: 'ossName', width: 200, align: 'left', formatter: 'linkOssName'}
					, {name: 'ossVersion', index: 'ossVersion', width: 70, align: 'left'}
					, {name: 'licenseName', index: 'licenseName', width: 200, align: 'left'}
					, {name: 'licenseType', index: 'licenseType', width: 70, align: 'center'}
					, {name: 'obligation', index: 'obligation', width: 70, align: 'left'}
					, {name: 'downloadLocation', index: 'downloadLocation', width: 150, align: 'left', formatter: 'link', formatoptions: {target:'_blank'}}
					, {name: 'homepage', index: 'homepage', width: 65, align: 'left', formatter: 'link2', formatoptions: {target:'_blank'}}
					, {name: 'summaryDescription', index: 'summaryDescription', width: 150, height: 50, align: 'left'}
					, {name: 'cveId', index: 'cveId', hidden:true}
					, {name: 'cvssScore', index: 'cvssScore', width: 50, align: 'center', formatter:'vuln'}
					<c:if test="${ct:isAdmin()}">
					, {name: 'creator', index: 'creator', width: 80, align: 'center'}
					, {name: 'createdDate', index: 'createdDate', width: 75, align: 'center', formatter:'date', formatoptions: {srcformat: 'Y-m-d H:i:s.t', newformat: 'Y-m-d'}}
					, {name: 'modifier', index: 'modifier', width: 80, align: 'center'}
					, {name: 'modifiedDate', index: 'modifiedDate', width: 75, align: 'center', formatter:'date', formatoptions: {srcformat: 'Y-m-d H:i:s.t', newformat: 'Y-m-d'}}
					</c:if>
					, {name: 'groupKey', index: 'groupKey', hidden:true
						, cellattr: function(rowId, val, rawObject, cm, rdata) {
							var result;
							var isGroup = false;
							
							if(groupBuffer == val){
								isGroup = true;
							}else{
								isGroup = false;
							}
							
							groupBuffer = val;
							
							if(isGroup){
								result = 'isgroup="true"';
							}else{
								result = 'isgroup="false"';
							}
							
							return result;
						 } 
					 }
				],
				rowNum: ${ct:getConstDef("DISP_PAGENATION_DEFAULT")},
				rowList: [${ct:getConstDef("DISP_PAGENATION_LIST_STR")}],
	 			autowidth: true,
				pager: '#pager',
				gridview: true,
				viewrecords: true,
				loadonce:false,
				height: 'auto',
				grouping:true,
				groupingView:{
					groupField:['groupKey'],
					groupColumnShow:[false]
				},	// group by 하는 컬럼명 입력
				gridComplete: function(){
					tableRefresh();
				},
				loadComplete: function(result) {
					totalRow = result.records;
					var rows = result.rows;
					var grid = this;

					if(totalRow == 0){
						var cStartDate = $("#cStartDate").val()||0;
						var cEndDate = $("#cEndDate").val()||0;
						var diffNum = +cStartDate - +cEndDate;
						
						
						var mStartDate = $("#mStartDate").val()||0;
						var mEndDate = $("#mEndDate").val()||0;
						var diffNum2 = +mStartDate - +mEndDate;

						if((diffNum > 0 && cEndDate > 0) 
								|| (diffNum2 > 0 && mEndDate > 0)){
							alertify.alert('<spring:message code="msg.common.search.check.date" />');
						}
					}
					
					//rowNum 초기화@@1
					$("#list").jqGrid('setGridParam', {rowNum:list.oldRowNum});					
					
					// 기존 그룹헤더에 있는 펼침버튼을 그룹별 첫번째 row의 group컬럼에 삽입 (첫번째 row를 그룹헤더 기능하도록 커스텀)
					$('[id^=listghead_0]').each(function(){
						var addBtn = "<span style='cursor:pointer;' class='groupBtns ui-icon ui-icon-plus tree-wrap-ltr' onclick=\"$('#list').jqGrid('groupingToggle','" + $(this).attr("id") + "'); $('#" + $(this).next().attr("id") + "').show(); return false;\"> </span>";
						var position = $(this).next().next().children().eq(1).text();

						if(position != ""){
							$(this).next().children().eq(0).append(addBtn);
						}
					});
					//그룹에 색깔주기
					//1. 그룹버튼 있는곳
					$('span.groupBtns').trigger('click').parent().parent().css('background-color' ,'#CDECFA');
					 
					//2. 이하 목록들
					$('tr td[isgroup="true"]', grid).parent().css('background-color' ,'#E1F6FA');
					
					//3. 이하 목록들에 그룹하위 표시 아이콘 주기
					$('tr td[isgroup="true"]', grid).parent().find('td:first')
					.prepend($('<span class="ui-icon ui-icon-carat-1-sw"></span>').css('display','inline-block'));
					
					//그룹 + - 토글
					$('span.groupBtns').on('click', function(e) {
						if($(this).hasClass('ui-icon-plus')) {
							$(this).removeClass('ui-icon-plus').addClass('ui-icon-minus');
						} else {
							$(this).removeClass('ui-icon-minus').addClass('ui-icon-plus');
						}
					});
					
					$('.listghead_0').hide();	// 기존 그룹헤더 숨김
					
					// 헤더에 버튼 추가
					if(!data.existTooltip){
						$('<span class="iconSet help right">Help</span>').appendTo($("#jqgh_list_obligation"))
							.attr("title", data.tooltipCont).tooltip({
								content: function () {
									return $(this).prop('title');
								}
						});
						$('<span class="iconSet help right">Help</span>').appendTo($("#jqgh_list_ossType"))
							.attr("title", data.tooltipCont2).tooltip({
								content: function () {
									return $(this).prop('title');
								}
						});
						
						$.ajax({
							type: 'GET',
							url: "/system/processGuide/getProcessGuide",
							data: {"id":"OSS_LIST_License_Type"},
							success : function(data){
								if(data.processGuide){
									var contents = data.processGuide.contents;
									
									if(contents && contents.trim()) {
										$('<span class="iconSet help right">Help</span>').appendTo($("#jqgh_list_licenseType"))
											.attr("title", contents).tooltip({
												content: function () {
													return $(this).prop('title');
												}
										});
									}
								}
							}
						});
						
						$.ajax({
							type: 'GET',
							url: "/system/processGuide/getProcessGuide",
							data: {"id":"OSS_List_Vulnerability"},
							success : function(data){
								if(data.processGuide){
									var contents = data.processGuide.contents;
									
									if(contents && contents.trim()) {
										$('<span class="iconSet help right">Help</span>').appendTo($("#jqgh_list_cvssScore"))
											.attr("title", contents).tooltip({
												content: function () {
													return $(this).prop('title');
												}
										});
									}
								}
							}
						});
						
						data.existTooltip = true;						
					}

					var datas = result.rows, rows=this.rows, row, className, rowsCount=rows.length,rowIdx=0;
					
					for(var _idx=0;_idx<rowsCount;_idx++) {
						row = rows[_idx];
						className = row.className;
						
						if (className.indexOf('jqgrow') !== -1) {
							rowid = row.id;
							rowData = result.rows[rowIdx++];
							var dataObject = datas.filter(function(a){
								return a.ossId==rowid}
							)[0];
							
							if(dataObject.deactivateFlag == "Y" && className.indexOf('excludeRow') === -1) {
								className= className + ' excludeRow';
							}
							
							row.className = className;
						} else if(className.indexOf('ui-subgrid') !== -1){
							rowIdx++;
						}
					}
				},
				ondblClickRow: function(rowid,iRow,iCol,e) {
					if(iCol!=0){
						var rowData = $("#list").jqGrid('getRowData',rowid);
						
						createTabInFrame(rowData['ossId']+'_Opensource', '#/oss/edit/'+rowData['ossId']);
					}
				},
				postData: $('#ossSearch').serializeObject()
			});
		}
	};
	
	// 헤더에 버튼 추가
	function displayUrl(cellvalue) {
		var icon1 = "<a href=\""+cellvalue+"\" class=\"urlLink\" target=\"_blank\">"+cellvalue+"</a>";
		
		return icon1;
	}
</script>