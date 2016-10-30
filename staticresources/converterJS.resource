// 18/08/2014 they are using centimetres instead of metres now

var IN2FT = 12;
var IN2M = 0.0254 * 100.0;		// we are using CM now
var M2IN = 39.3701 / 100.0;		// we are using CM now
var LB2KG = 0.4536;
var KG2LB = 2.2046;
var PRS1 = 10;		// 1 decimal precision
var PRS2 = 100;		// 2 decimal precision
var PRS3 = 1000;	// 3 decimal precision

function metresToFeetInches(metCls, ftId, inId)
{
	var metres = $('.' + metCls).val();
	var feet = '';
	var inches = '';
	
	if(metres && !isNaN(metres))
	{
		var totalInches = Math.round(metres * M2IN);
		feet = Math.floor(totalInches / IN2FT);
		inches = totalInches - feet*IN2FT;
	}
	
	$('#' + ftId).val(feet);
	$('#' + inId).val(inches);
}

function feetInchesToMetres(ftId, inId, metCls)
{
	var metres = '';
	var ft = $('#' + ftId).val();
	var ih = $('#' + inId).val();
	
	var feet = !ft ? 0 : ft;
	var inches = !ih ? 0 : ih;
	
	if((ft || ih) && !(isNaN(feet) || isNaN(inches)))	// at least one populated
	{
		metres = (feet * IN2FT + inches*1.0) * IN2M;
		metres = Math.round(metres);
	}
	
	$('.' + metCls).val(metres);
}

function kgToLb(kgCls, lbCls)
{
	convertWeight(kgCls, lbCls, KG2LB);
}

function lbToKg(lbCls, kgCls)
{
	convertWeight(lbCls, kgCls, LB2KG);
}

function convertWeight(srcCls, dstCls, cnvFctr)
{
	var src = $('.' + srcCls).val();
	var dst = '';
	
	if(src && !isNaN(src))
	{
		dst = Math.round(src * cnvFctr * PRS1) / PRS1;
	}
	
	$('.' + dstCls).val(dst);
}