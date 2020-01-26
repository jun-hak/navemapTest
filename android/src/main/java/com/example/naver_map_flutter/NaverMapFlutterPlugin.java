package com.example.naver_map_flutter;

import android.app.Activity;
import android.app.Application;
import android.os.Bundle;
import android.util.Log;

import java.util.concurrent.atomic.AtomicInteger;

import io.flutter.plugin.common.PluginRegistry.Registrar;

/** NaverMapFlutterPlugin */
public class NaverMapFlutterPlugin implements Application.ActivityLifecycleCallbacks {
  // https://github.com/flutter/plugins/blob/master/packages/google_maps_flutter/android/src/main/java/io/flutter/plugins/googlemaps/GoogleMapsPlugin.java
  static final int CREATED = 1;
  static final int STARTED = 2;
  static final int RESUMED = 3;
  static final int PAUSED = 4;
  static final int STOPPED = 5;
  static final int SAVEINSTANCESTATE = 6;
  static final int DESTROYED = 7;
  private final AtomicInteger state = new AtomicInteger(0);
  private final int registrarActivityHashCode;

  public NaverMapFlutterPlugin(Registrar registrar) {
    this.registrarActivityHashCode = registrar.activity().hashCode();
  }

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    if (registrar.activity() == null) {
      // When a background flutter view tries to register the plugin, the registrar
      // has no activity.
      // We stop the registration process as this plugin is foreground only.
      return;
    }
    NaverMapFlutterPlugin plugin = new NaverMapFlutterPlugin(registrar);
    registrar.activity().getApplication().registerActivityLifecycleCallbacks(plugin);
    registrar.platformViewRegistry().registerViewFactory("naver_map_flutter",
        new NaverMapFactory(plugin.state, registrar));
  }

  @Override
  public void onActivityCreated(Activity activity, Bundle bundle) {
    if (activity.hashCode() != registrarActivityHashCode) {
      return;
    }
    state.set(CREATED);
  }

  @Override
  public void onActivityStarted(Activity activity) {
    if (activity.hashCode() != registrarActivityHashCode) {
      return;
    }
    state.set(STARTED);
  }

  @Override
  public void onActivityResumed(Activity activity) {
    if (activity.hashCode() != registrarActivityHashCode) {
      return;
    }
    state.set(RESUMED);
  }

  @Override
  public void onActivityPaused(Activity activity) {
    if (activity.hashCode() != registrarActivityHashCode) {
      return;
    }
    state.set(PAUSED);
  }

  @Override
  public void onActivityStopped(Activity activity) {
    if (activity.hashCode() != registrarActivityHashCode) {
      return;
    }
    state.set(STOPPED);
  }

  @Override
  public void onActivitySaveInstanceState(Activity activity, Bundle bundle) {
    if (activity.hashCode() != registrarActivityHashCode) {
      return;
    }
    state.set(SAVEINSTANCESTATE);
  }

  @Override
  public void onActivityDestroyed(Activity activity) {
    if (activity.hashCode() != registrarActivityHashCode) {
      return;
    }
    activity.getApplication().unregisterActivityLifecycleCallbacks(this);
    state.set(DESTROYED);
  }
}
