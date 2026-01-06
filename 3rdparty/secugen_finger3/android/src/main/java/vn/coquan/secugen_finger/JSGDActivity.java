/*
 * Copyright (C) 2016 SecuGen Corporation
 *
 */

package vn.coquan.secugen_finger;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;

import SecuGen.FDxSDKPro.SGDeviceInfoParam;
import SecuGen.FDxSDKPro.SGWSQLib;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

import android.app.AlertDialog;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.IntentFilter;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.ColorMatrix;
import android.graphics.ColorMatrixColorFilter;
import android.graphics.Paint;
import android.hardware.usb.UsbDevice;
import android.hardware.usb.UsbManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.SeekBar;
import android.widget.TextView;
import android.widget.Switch;
import android.util.Base64;

import java.io.ByteArrayOutputStream;
import java.nio.ByteBuffer;
import java.util.HashMap;
import java.util.Map;

import SecuGen.FDxSDKPro.JSGFPLib;
import SecuGen.FDxSDKPro.SGAutoOnEventNotifier;
import SecuGen.FDxSDKPro.SGFDxConstant;
import SecuGen.FDxSDKPro.SGFDxDeviceName;
import SecuGen.FDxSDKPro.SGFDxErrorCode;
import SecuGen.FDxSDKPro.SGFDxSecurityLevel;
import SecuGen.FDxSDKPro.SGFDxTemplateFormat;
import SecuGen.FDxSDKPro.SGFingerInfo;
import SecuGen.FDxSDKPro.SGFingerPresentEvent;
import SecuGen.FDxSDKPro.SGImpressionType;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
public class JSGDActivity implements PluginRegistry.ActivityResultListener, Runnable, SGFingerPresentEvent{
    public JSGDActivity(Activity activity){
        this.activity = activity;
    }
    private static final String TAG = "SecuGen USB";
    private static final int IMAGE_CAPTURE_TIMEOUT_MS = 10000;
    private static final int IMAGE_CAPTURE_QUALITY = 50;

    private MethodChannel.Result pendingResult;
    private Activity activity;
    private byte[] mRegisterImage;
    private byte[] mVerifyImage;
    private byte[] mRegisterTemplate;
    private byte[] mVerifyTemplate;
    private int[] mMaxTemplateSize;
    private int mImageWidth;
    private int mImageHeight;
    private int mImageDPI;
    private int[] grayBuffer;
    private Bitmap grayBitmap;
    private IntentFilter filter; //2014-04-11
    private SGAutoOnEventNotifier autoOn;
     private boolean usbReceiverRegistered = false;
    private boolean mAutoOnEnabled;
    private int nCaptureModeN;
    private boolean bSecuGenDeviceOpened;
    private JSGFPLib sgfplib;
    private boolean usbPermissionRequested;
    //    private Switch mSwitchAutoOn;
    private int[] mNumFakeThresholds;
    private int[] mDefaultFakeThreshold;
    private boolean[] mFakeEngineReady;
    private boolean bRegisterAutoOnMode;
    private boolean bVerifyAutoOnMode;
    private boolean bFingerprintRegistered;
    private int mFakeDetectionLevel = 1;
    private PendingIntent mPermissionIntent;


    //////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////
    //This broadcast receiver is necessary to get user permissions to access the attached USB device
    private static final String ACTION_USB_PERMISSION = "com.android.example.USB_PERMISSION";
    private final BroadcastReceiver mUsbReceiver = new BroadcastReceiver() {
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            //Log.d(TAG,"Enter mUsbReceiver.onReceive()");
            if (ACTION_USB_PERMISSION.equals(action)) {
                synchronized (this) {
                    UsbDevice device = (UsbDevice) intent.getParcelableExtra(UsbManager.EXTRA_DEVICE);
                    if (intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false)) {
                        if (device != null) {
                            Log.d(TAG, "Permission granted for device: " + device.getDeviceName());
                            Log.d(TAG, "Vendor ID: " + device.getVendorId());
                            Log.d(TAG, "Product ID: " + device.getProductId());
                        } else {
                            Log.e(TAG, "mUsbReceiver.onReceive() Device is null");
                        }
                    } else {
                        Log.e(TAG, "mUsbReceiver.onReceive() permission denied for device " + device);
                    }
                }
            }
        }
    };


    public Bitmap toGrayscale(byte[] mImageBuffer, int width, int height) {
        byte[] Bits = new byte[mImageBuffer.length * 4];
        for (int i = 0; i < mImageBuffer.length; i++) {
            // Invert the source bits
            Bits[i * 4] = Bits[i * 4 + 1] = Bits[i * 4 + 2] = mImageBuffer[i];
            Bits[i * 4 + 3] = -1;// 0xff, that's the alpha.
        }

        Bitmap bmpGrayscale = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
        // Bitmap bm contains the fingerprint img
        bmpGrayscale.copyPixelsFromBuffer(ByteBuffer.wrap(Bits));
        return bmpGrayscale;
    }


    //////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////
    //Converts image to grayscale (NEW)
    public Bitmap toGrayscale(byte[] mImageBuffer)
    {
        byte[] Bits = new byte[mImageBuffer.length * 4];
        for (int i = 0; i < mImageBuffer.length; i++) {
            Bits[i * 4] = Bits[i * 4 + 1] = Bits[i * 4 + 2] = mImageBuffer[i]; // Invert the source bits
            Bits[i * 4 + 3] = -1;// 0xff, that's the alpha.
        }

        Bitmap bmpGrayscale = Bitmap.createBitmap(mImageWidth, mImageHeight, Bitmap.Config.ARGB_8888);
        bmpGrayscale.copyPixelsFromBuffer(ByteBuffer.wrap(Bits));
        return bmpGrayscale;
    }


    //////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////
    //Converts image to grayscale (NEW)
    public Bitmap toGrayscale(Bitmap bmpOriginal)
    {
        int width, height;
        height = bmpOriginal.getHeight();
        width = bmpOriginal.getWidth();
        Bitmap bmpGrayscale = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
        for (int y=0; y< height; ++y) {
            for (int x=0; x< width; ++x){
                int color = bmpOriginal.getPixel(x, y);
                int r = (color >> 16) & 0xFF;
                int g = (color >> 8) & 0xFF;
                int b = color & 0xFF;
                int gray = (r+g+b)/3;
                color = Color.rgb(gray, gray, gray);
                //color = Color.rgb(r/3, g/3, b/3);
                bmpGrayscale.setPixel(x, y, color);
            }
        }
        return bmpGrayscale;
    }


    private byte[] convertBitmapToFixedSize(Bitmap bitmap, int fixedWidth, int fixedHeight) {

        Bitmap largeBitmap = Bitmap.createBitmap(fixedWidth, fixedHeight, bitmap.getConfig());
        Canvas canvas = new Canvas(largeBitmap);
        canvas.drawColor(Color.WHITE);
        canvas.drawBitmap(bitmap, 0, 0, null);


        //calculate how many bytes our image consists of.
        int bytes = largeBitmap.getByteCount();

        ByteBuffer buffer = ByteBuffer.allocate(bytes); //Create a new buffer
        largeBitmap.copyPixelsToBuffer(buffer); //Move the byte data to the buffer

        byte[] array = buffer.array(); //Get the underlying array containing the data.

        //create a byte buffer that is 1/4 length of normal bitmap buffer
        //Secugen lib only understand this special 1/4-length byte buffer
        byte[] newBuffer = new byte[array.length / 4];

        for (int i = 0; i < array.length / 4; i++) {
            newBuffer[i] = array[i * 4];
        }

        return newBuffer;
    }

    //////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////
    //Converts image to binary (OLD)
    public Bitmap toBinary(Bitmap bmpOriginal)
    {
        int width, height;
        height = bmpOriginal.getHeight();
        width = bmpOriginal.getWidth();
        Bitmap bmpGrayscale = Bitmap.createBitmap(width, height, Bitmap.Config.RGB_565);
        Canvas c = new Canvas(bmpGrayscale);
        Paint paint = new Paint();
        ColorMatrix cm = new ColorMatrix();
        cm.setSaturation(0);
        ColorMatrixColorFilter f = new ColorMatrixColorFilter(cm);
        paint.setColorFilter(f);
        c.drawBitmap(bmpOriginal, 0, 0, paint);
        return bmpGrayscale;
    }

    //////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////
    public void DumpFile(String fileName, byte[] buffer)
    {
        //Uncomment section below to dump images and templates to SD card
    	/*
        try {
            File myFile = new File("/sdcard/Download/" + fileName);
            myFile.createNewFile();
            FileOutputStream fOut = new FileOutputStream(myFile);
            fOut.write(buffer,0,buffer.length);
            fOut.close();
        } catch (Exception e) {
            debugMessage("Exception when writing file" + fileName);
        }
       */
    }

    //////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////
    public void SGFingerPresentCallback (){
        autoOn.stop();
    }

    //////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////
    public void captureFingerPrint(MethodCall call, MethodChannel.Result result){
//            sgfplib.SetLedOn(true);
//                System.out.println("===============1======4==6===r===="+sgfplib.SetLedOn(true));
        Map args = call.arguments();
        mImageWidth = 100;
        mImageHeight = 100;
        long dwTimeStart = 0, dwTimeEnd = 0, dwTimeElapsed = 0;
        byte[] buffer = new byte[mImageWidth*mImageHeight];
        dwTimeStart = System.currentTimeMillis();
        long r = sgfplib.GetImage(buffer);
        Log.d("FingerScanner", "sgfplib.GetImage: " + r);
//        System.out.println("===============1======4==6===r===="+ r);
        String NFIQString;
//            long nfiq = sgfplib.ComputeNFIQ(buffer, mImageWidth, mImageHeight);
//            //long nfiq = sgfplib.ComputeNFIQEx(buffer, mImageWidth, mImageHeight,500);
//            NFIQString =  new String("NFIQ="+ nfiq);

        NFIQString = "";
        dwTimeEnd = System.currentTimeMillis();
        dwTimeElapsed = dwTimeEnd-dwTimeStart;
        DumpFile("capture.raw", buffer);
        //If fake detection engine is available, get score
        if ((mFakeEngineReady[0]) && (this.mFakeDetectionLevel > 1)) {
            double[] fakeScore = new double[1];
            r = sgfplib.FakeDetectionGetScore(fakeScore);
            double[] thresholdValue = new double[1];
            r = sgfplib.FakeDetectionGetThresholdValue(thresholdValue);
//            if (fakeScore[0] >= thresholdValue[0])
//            else
        }

        Log.d("FingerScanner", "buffer: " + buffer);
        System.out.println("buffer===============1======4==6===r===="+ buffer);
        buffer = null;
    }

    //////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////
    public void create(MethodCall call, MethodChannel.Result r){
        initUsbPermissionReceiver();
        Map re = new HashMap();

        mNumFakeThresholds = new int[1];
        mDefaultFakeThreshold = new int[1];
        mFakeEngineReady =new boolean[1];
        grayBuffer = new int[JSGFPLib.MAX_IMAGE_WIDTH_ALL_DEVICES* JSGFPLib.MAX_IMAGE_HEIGHT_ALL_DEVICES];
        for (int i=0; i<grayBuffer.length; ++i)
            grayBuffer[i] = Color.GRAY;
        grayBitmap = Bitmap.createBitmap(JSGFPLib.MAX_IMAGE_WIDTH_ALL_DEVICES, JSGFPLib.MAX_IMAGE_HEIGHT_ALL_DEVICES, Bitmap.Config.ARGB_8888);
        grayBitmap.setPixels(grayBuffer, 0, JSGFPLib.MAX_IMAGE_WIDTH_ALL_DEVICES, 0, 0, JSGFPLib.MAX_IMAGE_WIDTH_ALL_DEVICES, JSGFPLib.MAX_IMAGE_HEIGHT_ALL_DEVICES);
        int[] sintbuffer = new int[(JSGFPLib.MAX_IMAGE_WIDTH_ALL_DEVICES/2)*(JSGFPLib.MAX_IMAGE_HEIGHT_ALL_DEVICES/2)];
        for (int i=0; i<sintbuffer.length; ++i)
            sintbuffer[i] = Color.GRAY;
        Bitmap sb = Bitmap.createBitmap(JSGFPLib.MAX_IMAGE_WIDTH_ALL_DEVICES/2, JSGFPLib.MAX_IMAGE_HEIGHT_ALL_DEVICES/2, Bitmap.Config.ARGB_8888);
        sb.setPixels(sintbuffer, 0, JSGFPLib.MAX_IMAGE_WIDTH_ALL_DEVICES/2, 0, 0, JSGFPLib.MAX_IMAGE_WIDTH_ALL_DEVICES/2, JSGFPLib.MAX_IMAGE_HEIGHT_ALL_DEVICES/2);
        mMaxTemplateSize = new int[1];
//        mPermissionIntent = PendingIntent.getBroadcast(activity.getApplication(), 0, new Intent(ACTION_USB_PERMISSION), 0);

        sgfplib = new JSGFPLib(activity, (UsbManager)activity.getSystemService(Context.USB_SERVICE));
        long error = sgfplib.Init(SGFDxDeviceName.SG_DEV_AUTO);
        Log.d("fingerScanner", "Init error:" + error);
        bSecuGenDeviceOpened = false;
        usbPermissionRequested = false;
        mAutoOnEnabled = false;
        autoOn = new SGAutoOnEventNotifier(sgfplib, this);
        nCaptureModeN = 0;
        System.out.println("create-----------------------"+sgfplib);
        re.put("error", error);
        System.out.println("re-----------------------"+re);
        r.success(re);
        Log.d("FingerScanner", "create: " + sgfplib);

    }
    public void registerFingerPrint(MethodCall call, MethodChannel.Result r){

        int mImageWidth = 300;
        int mImageHeight = 400;
        long dwTimeStart = 0, dwTimeEnd = 0, dwTimeElapsed = 0;
        Map args = call.arguments();
        Map re = new HashMap();
        if (mRegisterImage != null)
            mRegisterImage = null;
        mRegisterTemplate = new byte[(int)mMaxTemplateSize[0]];
        mVerifyTemplate = new byte[(int)mMaxTemplateSize[0]];
        mRegisterImage = new byte[mImageWidth*mImageHeight];
        bFingerprintRegistered = false;
        dwTimeStart = System.currentTimeMillis();
        System.out.println("registerFingerPrint-----------------------1");
        long result = sgfplib.GetImageEx(mRegisterImage, IMAGE_CAPTURE_TIMEOUT_MS,IMAGE_CAPTURE_QUALITY);
        DumpFile("register.raw", mRegisterImage);

        Log.d("fingerScanner", "sgfplib.GetImageEx:" + result);
        System.out.println("registerFingerPrint-----------------------"+result);
        dwTimeEnd = System.currentTimeMillis();
        dwTimeElapsed = dwTimeEnd-dwTimeStart;
        dwTimeStart = System.currentTimeMillis();
        result = sgfplib.SetTemplateFormat(SecuGen.FDxSDKPro.SGFDxTemplateFormat.TEMPLATE_FORMAT_ISO19794);
        int quality1[] = new int[1];
        result = sgfplib.GetImageQuality(mImageWidth, mImageHeight, mRegisterImage, quality1);
        dwTimeEnd = System.currentTimeMillis();
        dwTimeElapsed = dwTimeEnd-dwTimeStart;
        SGFingerInfo fpInfo = new SGFingerInfo();
        fpInfo.FingerNumber = 1;
        fpInfo.ImageQuality = quality1[0];
        fpInfo.ImpressionType = SGImpressionType.SG_IMPTYPE_LP;
        fpInfo.ViewNumber = 1;

        for (int i=0; i< mRegisterTemplate.length; ++i)mRegisterTemplate[i] = 0;
        result = sgfplib.CreateTemplate(fpInfo, mRegisterImage, mRegisterTemplate);
        DumpFile("register.min", mRegisterTemplate);


        if (result == SGFDxErrorCode.SGFDX_ERROR_NONE) {
            bFingerprintRegistered = true;
            int[] size = new int[1];
            result = sgfplib.GetTemplateSize(mRegisterTemplate, size);
            re.put("result", result);
            re.put("status", "SUCCESS");
            re.put("image", mRegisterImage);
            System.out.println("=============SUCCESS=======4======"+result);

            Log.d("FingerScanner", "=============SUCCESS=======4======"+result);

        } else{
            re.put("result", result);
            re.put("image", mRegisterImage);

            Log.d("FingerScanner", "=============FAIL=======4======"+result);
            Log.d("FingerScanner", "Error: "+result);
            System.out.println("=============FAIL=======4======"+result);

        }
        r.success(re);
        mRegisterImage = null;
        fpInfo = null;
    }

    //////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////
    public void VerifyFingerPrint() {
        long dwTimeStart = 0, dwTimeEnd = 0, dwTimeElapsed = 0;
        if (!bFingerprintRegistered) {
            sgfplib.SetLedOn(false);
            return;
        }
        if (mVerifyImage != null)
            mVerifyImage = null;
        mVerifyImage = new byte[mImageWidth*mImageHeight];
        dwTimeStart = System.currentTimeMillis();
        long result = sgfplib.GetImageEx(mVerifyImage, IMAGE_CAPTURE_TIMEOUT_MS,IMAGE_CAPTURE_QUALITY);
        DumpFile("verify.raw", mVerifyImage);
        dwTimeEnd = System.currentTimeMillis();
        dwTimeElapsed = dwTimeEnd-dwTimeStart;
        dwTimeStart = System.currentTimeMillis();
        result = sgfplib.SetTemplateFormat(SecuGen.FDxSDKPro.SGFDxTemplateFormat.TEMPLATE_FORMAT_ISO19794);
        dwTimeEnd = System.currentTimeMillis();
        dwTimeElapsed = dwTimeEnd-dwTimeStart;

        int quality[] = new int[1];
        result = sgfplib.GetImageQuality(mImageWidth, mImageHeight, mVerifyImage, quality);

        SGFingerInfo fpInfo = new SGFingerInfo();
        fpInfo.FingerNumber = 1;
        fpInfo.ImageQuality = quality[0];
        fpInfo.ImpressionType = SGImpressionType.SG_IMPTYPE_LP;
        fpInfo.ViewNumber = 1;


        for (int i=0; i< mVerifyTemplate.length; ++i)
            mVerifyTemplate[i] = 0;
        dwTimeStart = System.currentTimeMillis();
        result = sgfplib.CreateTemplate(fpInfo, mVerifyImage, mVerifyTemplate);
        DumpFile("verify.min", mVerifyTemplate);
        dwTimeEnd = System.currentTimeMillis();
        dwTimeElapsed = dwTimeEnd-dwTimeStart;
        if (result == SGFDxErrorCode.SGFDX_ERROR_NONE) {

            int[] size = new int[1];
            result = sgfplib.GetTemplateSize(mVerifyTemplate, size);

            boolean[] matched = new boolean[1];
            dwTimeStart = System.currentTimeMillis();
            result = sgfplib.MatchTemplate(mRegisterTemplate, mVerifyTemplate, SGFDxSecurityLevel.SL_NORMAL, matched);
            dwTimeEnd = System.currentTimeMillis();
            dwTimeElapsed = dwTimeEnd - dwTimeStart;
            matched = null;
        }
        else {
            mVerifyImage = null;
            fpInfo = null;
        }
    }

    public void getData(MethodChannel.Result r){
        Map re = new HashMap();
        long error = sgfplib.OpenDevice(0);
        Log.d("fingerScanner", "OpenDevice:" + error);

        SGDeviceInfoParam device_info = new SGDeviceInfoParam();
        error = sgfplib.GetDeviceInfo(device_info);
        Log.d("fingerScanner", "GetDeviceInfo:" + error);

        int m_ImageWidth = 100;
        int m_ImageHeight = 100;
        if (error == SGFDxErrorCode.SGFDX_ERROR_NONE)
        {
            m_ImageWidth = device_info.imageWidth;
            m_ImageHeight = device_info.imageHeight;
        }

        byte[] buffer = new byte[m_ImageWidth*m_ImageHeight];
        long response = sgfplib.GetImageEx(buffer, 10000, 80); // Get image
        Log.d("fingerScanner", "Error getData:" + response);

        // Encode Image to send to WS
        SGWSQLib sgwsqLib = new SGWSQLib();
        int[] wsqImageOutSize = new int[1];
        Bitmap displayBitmap = toGrayscale(buffer, m_ImageWidth, m_ImageHeight);

        byte[] mRegisterImage512 = convertBitmapToFixedSize(displayBitmap, 512, 512);
        sgwsqLib.SGWSQGetEncodedImageSize(wsqImageOutSize, SGWSQLib.BITRATE_5_TO_1, mRegisterImage512, 512, 512, 8, 500);

        byte[] wsqImageOut = new byte[wsqImageOutSize[0]];
        sgwsqLib.SGWSQEncode(wsqImageOut, SGWSQLib.BITRATE_5_TO_1, mRegisterImage512, 512, 512, 8, 500);
//      writeLogToFile("out.wsq", null, wsqImageOut);
        String encodedBase64 = Base64.encodeToString(wsqImageOut, Base64.NO_WRAP);

        // image
        re.put("imageBase64", getEncoded64ImageStringFromBitmap(displayBitmap));
        re.put("fingerScanner", response);
        re.put("imageWidth", m_ImageWidth);
        re.put("imageHeight", m_ImageHeight);
//        re.put("data", encodedBase64);
        re.put("data", encodedBase64);

        r.success(re);
    }

    public String getEncoded64ImageStringFromBitmap(Bitmap bitmap) {
        ByteArrayOutputStream stream = new ByteArrayOutputStream();
        bitmap.compress(Bitmap.CompressFormat.JPEG, 70, stream);
        byte[] byteFormat = stream.toByteArray();

        // Get the Base64 string
        String imgString = Base64.encodeToString(byteFormat, Base64.NO_WRAP);

        return imgString;
    }
    @SuppressLint("UnspecifiedRegisterReceiverFlag")
    public void onCreate() {
        System.out.println("onCreate===============" );
        initUsbPermissionReceiver();
//        initSecugenDevices(false);
    }

    public void onResume() {
        registerUsbPermissionReceiver();
//        resumeSecugenDevice();
    }

    public void onPause() {
        try {
            unregisterUsbPermissionReceiver();
            pauseSecugenDevice();
        } catch (Exception e) {

        }
    }
    public void onDestroy(){
        destroySecugenDevice();
    }
        private void registerUsbPermissionReceiver(){
        if(!usbReceiverRegistered) {
            usbReceiverRegistered = true;
        }
    }

    private void unregisterUsbPermissionReceiver(){
        if(usbReceiverRegistered) {
            activity.getApplicationContext().unregisterReceiver(mUsbReceiver);
            usbReceiverRegistered = false;
        }
    }
    private void initUsbPermissionReceiver() {
        filter = new IntentFilter(ACTION_USB_PERMISSION);
        Intent explicitIntent = new Intent(ACTION_USB_PERMISSION);
        explicitIntent.setPackage(activity.getPackageName());
        //request USB Permissions
         //mPermissionIntent = PendingIntent.getBroadcast(context, 0, new Intent(ACTION_USB_PERMISSION), 0);

        if (android.os.Build.VERSION.SDK_INT > 33) {
            mPermissionIntent = PendingIntent.getBroadcast(activity.getApplicationContext(), 0, explicitIntent, PendingIntent.FLAG_IMMUTABLE | PendingIntent.FLAG_UPDATE_CURRENT);
        } else {
            mPermissionIntent = PendingIntent.getBroadcast(activity.getApplication(), 0, explicitIntent, PendingIntent.FLAG_MUTABLE);
        }
     }
    private void destroySecugenDevice(){
        if(sgfplib != null) {
            sgfplib.CloseDevice();
            sgfplib.Close();
        }
    }
    private void pauseSecugenDevice() {
        if (sgfplib.DeviceInUse()) {
            sgfplib.CloseDevice();
            mRegisterImage = null;
            mRegisterTemplate = null;
//            isPausedWhileInUse = true;
        }
    }
//    private void resumeSecugenDevice() {
//        if(isPausedWhileInUse) {
//            initSecugenDevices(true);
//        }
//    }
    public void run() {

        //Log.d(TAG, "Enter run()");
        //ByteBuffer buffer = ByteBuffer.allocate(1);
        //UsbRequest request = new UsbRequest();
        //request.initialize(mSGUsbInterface.getConnection(), mEndpointBulk);
        //byte status = -1;
        while (true) {


            // queue a request on the interrupt endpoint
            //request.queue(buffer, 1);
            // send poll status command
            //  sendCommand(COMMAND_STATUS);
            // wait for status event
            /*
            if (mSGUsbInterface.getConnection().requestWait() == request) {
                byte newStatus = buffer.get(0);
                if (newStatus != status) {
                    Log.d(TAG, "got status " + newStatus);
                    status = newStatus;
                    if ((status & COMMAND_FIRE) != 0) {
                        // stop firing
                        sendCommand(COMMAND_STOP);
                    }
                }
                try {
                    Thread.sleep(100);
                } catch (InterruptedException e) {
                }
            } else {
                Log.e(TAG, "requestWait failed, exiting");
                break;
            }
            */
        }
    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        return true;
    }

    private void clearMethodCallAndResult() {
        pendingResult = null;
    }

}