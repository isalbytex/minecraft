import java.lang.instrument.Instrumentation;
import java.lang.reflect.Method;
import java.util.List;
import java.util.Set;

public final class TrustZakkAgent2 {
  public static void agentmain(String args, Instrumentation inst) throws Exception {
    ClassLoader serverLoader = null;
    for (Class<?> loadedClass : inst.getAllLoadedClasses()) {
      if ("org.bukkit.Bukkit".equals(loadedClass.getName())) {
        serverLoader = loadedClass.getClassLoader();
        break;
      }
    }
    if (serverLoader == null) {
      System.out.println("[TrustZakkAgent2] org.bukkit.Bukkit classloader not found");
      return;
    }

    Class<?> bukkit = Class.forName("org.bukkit.Bukkit", false, serverLoader);
    Object pluginManager = bukkit.getMethod("getPluginManager").invoke(null);
    Object plugin = pluginManager.getClass().getMethod("getPlugin", String.class).invoke(pluginManager, "MejiClaimsV3");
    if (plugin == null) {
      System.out.println("[TrustZakkAgent2] MejiClaimsV3 not found");
      return;
    }

    Class<?> pluginClass = plugin.getClass();
    var claimsField = pluginClass.getDeclaredField("claims");
    claimsField.setAccessible(true);

    @SuppressWarnings("unchecked")
    List<Object> claims = (List<Object>) claimsField.get(plugin);
    int changed = 0;

    for (Object claim : claims) {
      Method trustedMethod = claim.getClass().getDeclaredMethod("trusted");
      trustedMethod.setAccessible(true);

      @SuppressWarnings("unchecked")
      Set<String> trusted = (Set<String>) trustedMethod.invoke(claim);
      if (trusted.add("zakk")) {
        changed++;
      }
      if (trusted.add("Zakk")) {
        changed++;
      }
    }

    Method saveClaims = pluginClass.getDeclaredMethod("saveClaims");
    saveClaims.setAccessible(true);
    saveClaims.invoke(plugin);

    System.out.println("[TrustZakkAgent2] Added Zakk trust entries: " + changed + " across claims: " + claims.size());
  }
}
