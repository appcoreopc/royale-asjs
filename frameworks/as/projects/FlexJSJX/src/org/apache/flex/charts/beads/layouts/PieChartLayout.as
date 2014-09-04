////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////
package org.apache.flex.charts.beads.layouts
{	
	import org.apache.flex.charts.core.IChart;
	import org.apache.flex.charts.core.IChartSeries;
	import org.apache.flex.charts.supportClasses.PieSeries;
	import org.apache.flex.charts.supportClasses.WedgeItemRenderer;
	import org.apache.flex.core.IBeadLayout;
	import org.apache.flex.core.IContentView;
	import org.apache.flex.core.ILayoutParent;
	import org.apache.flex.core.ISelectionModel;
	import org.apache.flex.core.IStrand;
	import org.apache.flex.core.UIBase;
	import org.apache.flex.events.Event;
	import org.apache.flex.events.IEventDispatcher;
	
	/**
	 *  The PieChartLayout class calculates the size and position of all of the itemRenderers for
	 *  a PieChart. 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10.2
	 *  @playerversion AIR 2.6
	 *  @productversion FlexJS 0.0
	 */
	public class PieChartLayout implements IBeadLayout
	{
		/**
		 *  constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10.2
		 *  @playerversion AIR 2.6
		 *  @productversion FlexJS 0.0
		 */
		public function PieChartLayout()
		{
		}
		
		private var _strand:IStrand;
		
		/**
		 *  @copy org.apache.flex.core.IBead#strand
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10.2
		 *  @playerversion AIR 2.6
		 *  @productversion FlexJS 0.0
		 */
		public function set strand(value:IStrand):void
		{
			_strand = value;
			IEventDispatcher(value).addEventListener("widthChanged", changeHandler);
			IEventDispatcher(value).addEventListener("childrenAdded", changeHandler);
			IEventDispatcher(value).addEventListener("itemsCreated", changeHandler);
			IEventDispatcher(value).addEventListener("layoutNeeded", changeHandler);
		}
		
		/**
		 * @private
		 */
		private function changeHandler(event:Event):void
		{
			var layoutParent:ILayoutParent = _strand.getBeadByType(ILayoutParent) as ILayoutParent;
			var contentView:IContentView = layoutParent.contentView as IContentView;
			contentView.removeAllElements();
			
			var selectionModel:ISelectionModel = _strand.getBeadByType(ISelectionModel) as ISelectionModel;
			var dp:Array = selectionModel.dataProvider as Array;
			if (!dp)
				return;
			
			var series:Array = IChart(_strand).series;
			var n:int = dp.length;
			trace("There are "+series.length+" series in this chart");
			
			var xpos:Number = 0;
			var useWidth:Number = UIBase(_strand).width;
			var useHeight:Number = UIBase(_strand).height;
			
			var maxYValue:Number = 0;
			var seriesMaxes:Array = [];
			var colors:Array = [0xFF0000, 0xFF9900, 0xFFFF00, 0x00FF00, 0x00FFcc, 0x0000FF, 0xcc00FF, 0xFF00cc, 0x888888, 0x333333, 0xFFcc99];
			
			for (var s:int = 0; s < series.length; s++)
			{
				var pcs:PieSeries = series[s] as PieSeries;
				
				for (var i:int = 0; i < n; i++)
				{
					var data:Object = dp[i];
					var field:String = pcs.dataField;
					
					var yValue:Number = Number(data[field]);
					maxYValue += yValue;
					
					seriesMaxes.push( {yValue:yValue, percent:0, arc:0} );
				}
				
				for (i=0; i < n; i++)
				{
					var obj:Object = seriesMaxes[i];
					obj.percent = obj.yValue / maxYValue;
					obj.arc = 360.0*obj.percent;					
				}
				
				var start:Number = 0;
				var end:Number = 0;
				var radius:Number = Math.min(useWidth,useHeight)/2;
				var centerX:Number = useWidth/2;
				var centerY:Number = useHeight/2;
								
				for (i=0; i < n; i++)
				{
					obj = seriesMaxes[i];
					data = dp[i];
					
					var child:WedgeItemRenderer = (series[s] as IChartSeries).itemRenderer.newInstance() as WedgeItemRenderer;
					child.itemRendererParent = contentView;
					child.data = data;
					child.fillColor = colors[i];
					contentView.addElement(child);
					
					end = start + (360.0 * obj.percent);
					var arc:Number = 360.0 * obj.percent;
					trace("Draw arc from "+start+" to "+(start+arc));
					child.drawWedge(centerX, centerY, start*Math.PI/180, arc*Math.PI/180, radius);
					
					start += arc;
				}
			}
			
			IEventDispatcher(_strand).dispatchEvent(new Event("layoutComplete"));
		}
	}
}