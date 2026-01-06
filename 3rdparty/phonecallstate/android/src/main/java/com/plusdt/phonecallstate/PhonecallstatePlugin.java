package com.plusdt.phonecallstate;

import android.app.Activity;
import android.content.Context;
import android.os.Build;
import android.os.Looper;
import android.telephony.PhoneStateListener;
import android.telephony.TelephonyManager;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** PhonecallstatePlugin */
public class PhonecallstatePlugin implements FlutterPlugin, ActivityAware, MethodCallHandler {

  private Activity activity;
  private static final String TAG = "KORDON";//MyClass.class.getSimpleName();

  TelephonyManager tm;
  private MethodChannel channel;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "com.plusdt.phonecallstate");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("phoneTest.PhoneIncoming")) {
      Log.i(TAG,"phoneIncoming Test implementation");
      // Create timer to invokemethod phone incoming
      //double seconds=Double(call.arguments.toFloat());

    }
    else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }


  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    this.activity = binding.getActivity();
    TelephonyManager tm = (TelephonyManager) this.activity.getSystemService(Context.TELEPHONY_SERVICE);
    tm.listen(mPhoneListener, PhoneStateListener.LISTEN_CALL_STATE);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {

  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

  }

  @Override
  public void onDetachedFromActivity() {

  }

  private final PhoneStateListener mPhoneListener = new PhoneStateListener() {
    public void onCallStateChanged(int state, String incomingNumber) {
      try {
        switch (state) {
          case TelephonyManager.CALL_STATE_RINGING:
            // do something...

            channel.invokeMethod("phone.incoming", true);
            break;

          case TelephonyManager.CALL_STATE_OFFHOOK:
            channel.invokeMethod("phone.connected", true);
            // do something...
            break;

          case TelephonyManager.CALL_STATE_IDLE:
            channel.invokeMethod("phone.disconnected", true);
            // do something...
            break;
          default:
            Log.d(TAG, "Unknown phone state=" + state);
        }
      } catch (Exception e) {
        Log.e("TAG", "Exception");
      }
      //catch (RemoteException e) {}
    }
  };
}
