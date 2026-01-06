package vn.coquan.secugen_finger;

import android.app.Activity;
import android.content.Context;
import android.hardware.usb.UsbManager;

import androidx.annotation.NonNull;

import java.util.Map;
import android.app.Activity;
import android.util.Log;

import androidx.appcompat.app.AppCompatDelegate;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import SecuGen.Driver.Constant;
import SecuGen.FDxSDKPro.JSGFPLib;
import SecuGen.FDxSDKPro.SGANSITemplateInfo;
import SecuGen.FDxSDKPro.SGAutoOnEventNotifier;
import SecuGen.FDxSDKPro.SGFDxConstant;
import SecuGen.FDxSDKPro.SGFDxDeviceName;
import SecuGen.FDxSDKPro.SGFDxErrorCode;
import SecuGen.FDxSDKPro.SGFDxSecurityLevel;
import SecuGen.FDxSDKPro.SGFDxTemplateFormat;
import SecuGen.FDxSDKPro.SGFPImageInfo;
import SecuGen.FDxSDKPro.SGFingerInfo;
import SecuGen.FDxSDKPro.SGFingerPresentEvent;
import SecuGen.FDxSDKPro.SGISOTemplateInfo;
import SecuGen.FDxSDKPro.SGImpressionType;
import SecuGen.FDxSDKPro.SGWSQLib;


/** SecugenFingerPlugin */
public class SecugenFingerPlugin implements MethodCallHandler, FlutterPlugin, ActivityAware {

  private static final String CHANNEL = "secugen_finger";
  private JSGDActivity delegate;

  private ActivityPluginBinding activityPluginBinding;



  /**
   * Plugin registration.
   */
  public static void registerWith(PluginRegistry.Registrar registrar) {

    SecugenFingerPlugin plugin = new SecugenFingerPlugin();

    plugin.setupEngine(registrar.messenger());
    JSGDActivity delegate = plugin.setupActivity(registrar.activity());
    registrar.addActivityResultListener(delegate);

  }

  private void setupEngine(BinaryMessenger messenger) {
    MethodChannel channel = new MethodChannel(messenger, CHANNEL);
    channel.setMethodCallHandler(this);
  }

  public JSGDActivity setupActivity(Activity activity) {
    delegate = new JSGDActivity(activity);
    return delegate;
  }


  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("capture")) {
      delegate.captureFingerPrint(call, result);
    }else if (call.method.equals("register")) {
      delegate.registerFingerPrint(call, result);
    }else
      if (call.method.equals("create")) {
      delegate.create(call, result);
    }else    if (call.method.equals("onCreate")) {
      delegate.onCreate();
    }else
      if (call.method.equals("onResume")) {
      delegate.onResume();
    }else
      if (call.method.equals("getData")) {
      delegate.getData(result);
      Log.d("fingerScanner", "Finish getting image");
    } else {
      result.notImplemented();
    }
  }

  //////////////////////////////////////////////////////////////////////////////////////

  @Override
  public void onAttachedToEngine(FlutterPluginBinding flutterPluginBinding) {
    setupEngine(flutterPluginBinding.getBinaryMessenger());
  }

  @Override
  public void onAttachedToActivity(ActivityPluginBinding activityPluginBinding) {

    setupActivity(activityPluginBinding.getActivity());
    this.activityPluginBinding = activityPluginBinding;
    activityPluginBinding.addActivityResultListener(delegate);
  }
  //////////////////////////////////////////////////////////////////////////////////////

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding flutterPluginBinding) {
    // no need to clear channel
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity();
  }

  @Override
  public void onDetachedFromActivity() {
    activityPluginBinding.removeActivityResultListener(delegate);
    activityPluginBinding = null;
    delegate = null;
  }

  @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding activityPluginBinding) {
    onAttachedToActivity(activityPluginBinding);
  }
}
