/**
 * Shader animation for hero section — CommonGround theme (#007AFF, #0051D5)
 * Uses Three.js for WebGL shader background
 */
(function () {
  const vertexShader = `
    void main() {
      gl_Position = vec4(position, 1.0);
    }
  `;

  const fragmentShader = `
    precision highp float;
    uniform vec2 resolution;
    uniform float time;
    uniform vec3 primaryColor;
    uniform vec3 accentColor;

    void main(void) {
      vec2 uv = (gl_FragCoord.xy * 2.0 - resolution.xy) / min(resolution.x, resolution.y);
      float t = time * 0.05;
      float lineWidth = 0.002;

      float intensity = 0.0;
      for(int j = 0; j < 3; j++){
        for(int i = 0; i < 5; i++){
          intensity += lineWidth * float(i * i) / abs(fract(t - 0.01 * float(j) + float(i) * 0.01) * 5.0 - length(uv) + mod(uv.x + uv.y, 0.2));
        }
      }
      intensity = clamp(intensity, 0.0, 1.0);

      vec3 color = mix(accentColor, primaryColor, intensity);
      gl_FragColor = vec4(color, 1.0);
    }
  `;

  function initShaderHero() {
    const container = document.getElementById('hero-shader-container');
    if (!container || typeof THREE === 'undefined') return;

    const camera = new THREE.Camera();
    camera.position.z = 1;

    const scene = new THREE.Scene();
    const geometry = new THREE.PlaneGeometry(2, 2);

    const primaryColor = new THREE.Vector3(0, 122 / 255, 255 / 255);   // #007AFF
    const accentColor = new THREE.Vector3(0, 81 / 255, 213 / 255);    // #0051D5

    const uniforms = {
      time: { value: 1.0 },
      resolution: { value: new THREE.Vector2() },
      primaryColor: { value: primaryColor },
      accentColor: { value: accentColor },
    };

    const material = new THREE.ShaderMaterial({
      uniforms: uniforms,
      vertexShader: vertexShader,
      fragmentShader: fragmentShader,
    });

    const mesh = new THREE.Mesh(geometry, material);
    scene.add(mesh);

    const renderer = new THREE.WebGLRenderer({ antialias: true });
    renderer.setPixelRatio(window.devicePixelRatio);
    renderer.setClearColor(0x0051d5, 1);

    container.appendChild(renderer.domElement);

    function onResize() {
      const w = container.clientWidth;
      const h = container.clientHeight;
      renderer.setSize(w, h);
      uniforms.resolution.value.x = renderer.domElement.width;
      uniforms.resolution.value.y = renderer.domElement.height;
    }

    onResize();
    window.addEventListener('resize', onResize);

    let animId;
    function animate() {
      animId = requestAnimationFrame(animate);
      uniforms.time.value += 0.05;
      renderer.render(scene, camera);
    }
    animate();

    return function cleanup() {
      window.removeEventListener('resize', onResize);
      cancelAnimationFrame(animId);
      if (container.contains(renderer.domElement)) {
        container.removeChild(renderer.domElement);
      }
      renderer.dispose();
      geometry.dispose();
      material.dispose();
    };
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initShaderHero);
  } else {
    initShaderHero();
  }
})();
