package away3d.materials
{
	import away3d.animators.data.NullAnimation;
	import away3d.cameras.Camera3D;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.containers.View3D;
	import away3d.core.base.Object3D;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	
	/**
	 * CCTV Material allows the creation of a seperate view and camera to render a scene from another angle. The render is drawn
	 * to a the bitmapdata. Map that to a plane or model and you have a CCTV like (Picture in Picture)!
	 * 
	 * @author jerome@wemakedotcoms
	 * 
	 */
	
	public class CCTVMaterial extends BitmapMaterial
	{
		
		
		/**
		 * @author desaturate code from Ralph Hauwert
		 */
		private static const ORIGIN : Point = new Point();
		
		/**
		 * Desaturate color vector, by Paul Haeberli
		 *      
		 * http://www.graficaobscura.com/matrix/index.html
		 */
		private static var rl:Number = 0.3086;
		private static var gl:Number = 0.6094;
		private static var bl:Number = 0.0820;
		
		private static var cmf:ColorMatrixFilter = new ColorMatrixFilter([rl,gl,bl,0,0,rl,gl,bl,0, 0,rl,gl,bl,0,0,0,0,0,1,0]);
		
		
		
		private var _matrix:Matrix;
		private var _view:View3D;
		private var _camera:Camera3D;
		private var _cameraTarget:Object3D
		private var _container:Sprite;
		private var _bmd:BitmapData;
		private var _greyscale:Boolean;
		private var _border:uint;
		
				
		public function CCTVMaterial(view:View3D, w:int, h:int, container:Sprite, cctvCamera:Camera3D = null, materialWidth:int = 128, materialHeight:int = 128)
		{
			
			super(new BitmapData(materialWidth, materialHeight, false, 0x000000), true, false, false);
			
			_border = 0;
			
			_container = container;
			
			_matrix = new Matrix;
			_matrix.scale( materialWidth / w, materialHeight / h );
			
			_camera = cctvCamera || new Camera3D();
			
			if( !cctvCamera ) PerspectiveLens( _camera.lens ).fieldOfView = 100;
			
			_view = new View3D( view.scene, _camera );
			_view.backgroundColor = view.backgroundColor;
			_view.x = -w;
			_view.width = w;
			_view.height = h;
			
			_bmd = new BitmapData(w, h, transparent, 0x000000);
			
			// hack
			_container.addChild( _view );
			_view.visible = false;
			
		}

		
		
		public function update():void
		{
			// update the camera target
			if(_cameraTarget) camera.lookAt( _cameraTarget.position );
			
			// render the CCTV view
			_view.render(false);
			
			// no context? Bolt!
			if(!_view.renderer.context) return;
			
			_bmd.lock();
			bitmapData.lock();
			
			// draw to temp bitmap
			_view.renderer.context.drawToBitmapData( _bmd );
			
			// Draw to material
			bitmapData.draw( _bmd, _matrix, null, null, new Rectangle(_border, _border, bitmapData.width - _border*2, bitmapData.height - _border*2), smooth );
			if(_greyscale) bitmapData.applyFilter(bitmapData, bitmapData.rect, ORIGIN, cmf );
			updateTexture();
			
			_bmd.unlock();
			bitmapData.unlock();
			
			_view.renderer.context.present();
			
		}
		
		override public function dispose(deep:Boolean):void
		{
			
			if( _container && _container.contains( _view ) ) _container.removeChild( _view );
			
			_bmd.dispose();
			_camera.dispose( deep );
			_view.dispose();
			
			_matrix = null;
			_bmd = null;
			_camera = null;
			_cameraTarget = null;
			_view = null;
			_container = null;
			
			super.dispose( deep );
			
		}
		
		public function get camera():Camera3D
		{
			return _camera;
		}

		public function set camera(value:Camera3D):void
		{
			_camera = value;
		}

		public function get view():View3D
		{
			return _view;
		}

		public function set view(value:View3D):void
		{
			_view = value;
		}

		public function get greyscale():Boolean
		{
			return _greyscale;
		}

		public function set greyscale(value:Boolean):void
		{
			_greyscale = value;
		}

		public function get cameraTarget():Object3D
		{
			return _cameraTarget;
		}

		public function set cameraTarget(value:Object3D):void
		{
			_cameraTarget = value;
		}

		public function get border():uint
		{
			return _border;
		}

		public function set border(value:uint):void
		{
			_border = value;
		}


	}
}