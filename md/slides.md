<!-- .slide: data-transition="convex" -->
## Manage <span style="color:red">Inhouse Openstack</span><br/> the hard way

<a href="mailto:liquidnuker@gmail.com">Eohyung Lee</a>

---
<!-- .slide: data-transition="convex" -->

<img src="md/images/leoh0.jpeg" width="100" height="100" />
### about me
* [이어형](http://leoh0.github.io/)
  - software engineer(라고 쓰고 cloud engineer 아니.. openstack engineer.. A.K.A VM dealer)
  - 개발, 리서치(라고 쓰고 온갖 삽질), 운영, 아키텍팅 등

* ( ~현재) [private cloud service in kakao about 3 years](http://superuser.openstack.org/articles/kakaotalk-speaks-volumes-about-the-future-of-cloud-services/)
  - 현재 약 10000+ VMs, 4 regions
  - grizzly -> havana -> icehouse -> juno -> kilo 업그레이드
* ( ~2014) public cloud storage service in KT about 3 years

---
<!-- .slide: data-transition="convex" -->
### ✨오늘의 주제✨

<ul>
<span class="fragment fade-out"><li>openstack을 어떻게 하면 힘들게 관리할까.</li></span>
<span class="fragment"><li>카카오는 openstack을 어떻게 관리하고 있는가?</li></span>
</ul>

<span class="fragment">(힘들게ㅠㅠ)</span>

---
<!-- .slide: data-transition="convex" -->
### 또 그 주제인가?

[재탕](https://youtu.be/TTidtRmOqYU)인가 싶지만 <br/>오늘은 특정한 코드관리만 따놓고 이야기를

<a href="https://openstackreactions.wordpress.com/2014/12/04/starting-a-vm-in-my-newly-deployed-openstack-cloud/"><img src="md/images/rev.gif" width="640" /></a>

---
<!-- .slide: data-transition="convex" -->

### openstack in <span style="color:yellow">KAKAO</span>

* kfield
<ul>
<span class="fragment"><li>vagrant + chef기반 배포 코드</li></span>
<span class="fragment"><li>vagrant-libvirt + openvswitch + quagga 등으로 <br/>linux box에서 cluster 형태로 테스트 및 배포 코드 개발</li></span>
</ul>

* openstack code
<ul>
<span class="fragment"><li>주요 repository 미러링</li></span>
<span class="fragment"><li>특정 릴리즈의 stable branch에 <br/> custom commit 들을 패치해서 사용</li></span>
</span>
</ul>

---
<!-- .slide: data-transition="convex" -->

### 왜 kfield를 만들었는가?

* 당시 마땅한 배포 프로젝트는 없어서..
<ul>
<span class="fragment"><li>오픈소스 배포 코드들은 특수한 상황에 <br/>맞게만 되어 있어서 사용 못함</li></span>
<span class="fragment"><li>오픈소스 배포 코드들은 openstack보단 배포 코드 전문가가 <br/>작성을 많이하여 디테일한 관리가 부족함</li></span>
</ul>

* 네트워크 아키텍쳐에 맞는 구성을 하려면 all-in-one이 아닌 <br/>cluster 형태가 필요함
<ul>
<span class="fragment"><li>network의 가상화가 필요</li></span>
<span class="fragment"><li>ex.) bgp 아키텍쳐를 테스트를 위한 quagga</li></span>
</ul>
  
---
<!-- .slide: data-transition="convex" -->

### 사실은..

* [누군가](https://github.com/whitekid) chef code로 거의 다 짜놔서..
<ul>
<span class="fragment"><li>초기엔 virsh로 만든 클러스터에 chef로 배포</li></span>
<span class="fragment"><li>나중에 [누군가](https://github.com/sstrato) vagrant-libvirt 를 붙이면서 <br/> <span style="color:green">kfield(kakao + field)</span>라 이름지음</li></span>
</ul>

---
<!-- .slide: data-transition="convex" -->

### 테스트시 네트워크 가상화가 왜 필요한가?

* 초창기 테스트 모습

<img src="md/images/2016-10-10_11-34-10.jpg" />

provider network 를 테스트 하기 위해서는 필수 

---
<!-- .slide: data-transition="convex" -->

### 배포 코드 구성

대부분 프로젝트 기준으로 아래에 틀에서 크게 벗어나지 않음

1. <span class="fragment" data-fragment-index="1"><span class="fragment highlight-red"><span class="fragment highlight-red" data-fragment-index="7">패키지 설치 <span class="fragment" data-fragment-index="8"><= patch</span></span></span>
2. <span class="fragment" data-fragment-index="2"><span class="fragment highlight-red" data-fragment-index="6">컨피그 변경</span></span>
3. <span class="fragment" data-fragment-index="3">DB 마이그레이션</span> 
4. <span class="fragment" data-fragment-index="4">프로세스 시작</span> 
5. <span class="fragment" data-fragment-index="5">부트스트래핑</span>

---
<!-- .slide: data-transition="convex" -->

### 뭘 patch 하는가?

1. <span class="fragment">해당 버전때 적용안된 bugfix</p>
2. <span class="fragment">쓰고 싶으나 아직 못쓰는 추가적인 feature</p>
3. <span class="fragment">custom codes</p>

---
<!-- .slide: data-transition="convex" -->

### custom codes를 왜 쓰는가?

다른 이유도 많지만 그중에서도

<img src="md/images/2016-10-07_23-58-25.jpg" />

<span class="fragment">우리에겐 선택할 수 있는 네트워크 아키텍쳐가 제한적이었음</span>

---
<!-- .slide: data-transition="convex" -->

### 왜 처음에 vlan을 선택 했었나?

<ul>
<span class="fragment"><li>private cloud 에서는 tenant private network이 필수는 아님</li></span>
<span class="fragment"><li>tunneling network를 쓰기 위해선 mtu 지옥과 en/decapsulation 가속이 필요( $$ )</li></span>
<span class="fragment"><li>당시엔 openvswitch 아키텍쳐는 neutron-plugin-agent 가 restart 할 시 모든 자신의 네트워크 정보를 neutron-server로 부터 받아옴
  - tunneling network는 full mesh 정보를 구축하면 대량의 RPC call이 일어남
  - 더블어 네트워크 초기화 까지 일어 났기 때문에 만약 대량의 RPC call로 rabbitmq 장애 발생시 네트워크가 복구 안됨</li></span>
</ul>

---
<!-- .slide: data-transition="convex" -->

### 하지만 vlan을 쓰기시작하면..

<ul>
<span class="fragment"><li>large L2가 불가능</li></span>
<span class="fragment"><li>전용랙이 아닐시 switch port 단위로 network admin이 작업 필요</li></span>
<span class="fragment"><li>neutron segement id는(vlan id)는 network 단위기 때문에 vlan : subnet = 1 : n 을 지원해야함</li></span>
</ul>

---
<!-- .slide: data-transition="convex" -->

### 그래서 결국 네트워크 아키텍쳐를 만들어야 했음..

<a href="https://www.youtube.com/watch?v=WD1sk_SX_8A"><img src="md/images/2016-10-10_11-43-46.jpg" /></a>

---
<!-- .slide: data-transition="convex" -->

### custom codes를 <br/>왜 upstream에 올리지 않는가?

1. 스페셜 케이스 들이기 때문에.. 그 이유 외에는

<a href="http://devopsreactions.tumblr.com/post/99894521928/so-many-tickets-so-little-time"><img src="md/images/tumblr_inline_nczwr2hv7N1raprkq.gif" /></a>

<ol start="2">
<span class="fragment"><li>시간부족 & 노력부족 <br/>(master branch와 stable branch 코드를 다 봐야하는 아픔이..)</li></span>
</ol>
---
<!-- .slide: data-transition="convex" -->

### 아무튼 어떻게 패치하나? (과거)

PATCH_FILE

``` diff
...
diff --git a/keystone/common/config.py b/keystone/common/config.py
index 85c49f8..b455d5f 100644
--- a/keystone/common/config.py
+++ b/keystone/common/config.py
@@ -69,6 +69,8 @@ FILE_OPTIONS = {
                         '(eg /prefix/v2.0) or the endpoint should be found on '
                         'a different server.'),
+        cfg.IntOpt('public_workers', default=1),
+        cfg.IntOpt('admin_workers', default=1),
         cfg.StrOpt('onready',
                    help='onready allows you to send a notification when the '
...
```

PATCH!!

``` bash
apt-get install -y keystone
cd /usr/lib/python2.7/dist-packages
patch -p1 -i ${PATCH_FILE}
```

---
<!-- .slide: data-transition="convex" -->

### 패치 관리가 힘듬.. (과거)

<ul>
<span class="fragment"><li>한 프로젝트에 여러개 patch가 생기면서 patch 하는 순서를 잘 관리해야함</li></span>
<span class="fragment"><li>패치를 업데이트해야 되면 이후 패치 전체를 다시 수정해야 함</li></span>
<span class="fragment"><li>배포 하다 package가 업데이트 되면서 예상 못한 타이밍에 patch가 실패하는 일들이 발생</li></span>
</ul>

<img src="md/images/2016-10-10_14-41-42.jpg" />

---
<!-- .slide: data-transition="convex" -->

### 결국 source level 로 설치 (현재)

<ul>
<span class="fragment"><li>debian package를 repackaging 했으나 <br/>dependency 관리가 지옥</li></span>
<span class="fragment"><li>결국 version control 할 수 있는 git을 사용</li></span>
<span class="fragment"><li>main repo를 mirroring 하면서 custom commit 들을 <br/>버전마다 지속적인 rebase가 필요</li></span>
</ul>

<img src="md/images/2016-10-10_13-55-45.jpg" />

---
<!-- .slide: data-transition="convex" -->

### 이왕 source로 설치하는 김에 python version도 고정

>여러 버전의 os 들을 섞어서 써야하는 <br/>일들이 발생

<ul>
<span class="fragment"><li>[pyenv](https://github.com/yyuu/pyenv) 로 특정 version의 python을 [설치](https://gist.githubusercontent.com/leoh0/57ba9bf1bc632836e2ac27dd15c20e37/raw/145a4bb8ec6267a7cd3479f4c7e32b8247b2108a/setup_pyenv.sh)하도록 함</li></span>
<span class="fragment"><li>이후 모든 python-path 들에 대한 관리가 필요</li></span>
</ul>

---
<!-- .slide: data-transition="convex" -->

### 결국 그러려면 python library 관리 필요

<ul>
<span class="fragment"><li>[requirements](https://github.com/openstack/requirements/)를 이용해서 전체 requirements 를 설치</li></span>
<span class="fragment"><li>이걸 매번 반복하면 엄청난 양을 compile 하는것을 볼 수 있음..</li></span>
<span class="fragment"><li>그렇기 때문에 가능한 wheel 로 [미리 compile 해두면](https://github.com/leoh0/wheelbuilder-base-public) 시간 <br/>절약 가능</li></span>
</ul>

추후에 아래와 같이 사용

```
# 여기에서 전체 requiments 설치
cd openstack/requirements
pip install --use-wheel --no-index --find-links=${URL} -c upper-constraints.txt -r global-requirements.txt
# 위에서 전체 requiments 가 설치 되었으므로 아래에서는 거의 코드만 설치됨
cd openstack/keystone
pip install .
```

---
<!-- .slide: data-transition="convex" -->

### 이렇게 되었을때 배포 코드 구성

* 패키지 설치 대신 결국
  1. pyenv 설치
  2. python 설치
  3. global requirements 설치
  4. 코드 설치

---
<!-- .slide: data-transition="convex" -->

### 그래서 앞으로.. container로 배포가 필요

<ul>
<span class="fragment"><li>배포 중간 문제가 생기기 시작하면 <br/>결국 container가 필요한가 싶어짐</li></span>
<span class="fragment"><li>하지만 아직 docker 외에 별다른 옵션은 없고 <br/>docker로도 [network namespace](https://github.com/openstack/kolla/blob/master/docker/neutron/neutron-base/ip_wrapper.py) 관리가 불편함</li></span>
<span class="fragment"><li>아무튼 docker(>= 1.10)기준으로 <br/>[privileged, host 자원을 쓰는것이 필요함](https://github.com/openstack/kolla/blob/master/specs/containerize-openstack.rst#proposed-change)</li></span>
</ul>

---
<!-- .slide: data-transition="convex" -->

### 아무튼 현재상황(git)에서 <br/>다음 release 로 업데이트 해야하면 필요한게..

<a href="https://openstackreactions.wordpress.com/2013/11/22/jenkins-fails-sending-a-review-update-jenkins-fails-sending-a-review-update/"><img src="md/images/track-and-fail.gif" width="480" /></a>

<ul>
<span class="fragment"><li>패치를 새로운 release로 rebase 필요 <br/>(Welcome to Rebase Hell)</li></span>
<span class="fragment"><li>새로운 requirements 에 대한 python library 관리</li></span>
<span class="fragment"><li>물론 버그는 덤</li></span>
</ul>

---
<!-- .slide: data-transition="convex" -->

### 다만 upgrade code는 그렇게 복잡하지 않음 <br/>(준비)

juno upgrade시 준비한 실제 code

* chef 종료
```
knife ssh roles:* 'service chef-client stop'
```

* 업로드
```
berks install && berks upload --force # for safe reupload
knife role from file roles/*.rb
knife environment from file environments/$(chefvm current).rb
```

* control service stop
```
knife ssh roles:*control* '/root/bin/os-service.sh stop'
```

* compute service stop
```
knife ssh roles:*compute* '/root/bin/os-service.sh stop'
```

---
<!-- .slide: data-transition="convex" -->

### 다만 upgrade code는 그렇게 복잡하지 않음 <br/>(업그레이드)

* lb
```
chef-client -c /etc/chef/client.rb -l fatal -F doc
```

* db
```
rm -rf /opt/openstack
chef-client -c /etc/chef/client.rb -l fatal -F doc
```

* control
```
rm -rf /opt/openstack
chef-client -c /etc/chef/client.rb -l fatal -F doc
```

* compute dhcp
```
rm -rf /opt/openstack
chef-client -c /etc/chef/client.rb -l fatal -F doc
ps -ef | grep neutron-ns-metadata-proxy | grep -v grep | awk '{print $2}' | xargs -L1 -I{} kill -15 {} ; service neutron-dhcp-agent restart
```

---
<!-- .slide: data-transition="convex" -->

### 오! 다 된거 같은데 production에 적용해 볼까..

<a href="https://openstackreactions.wordpress.com/2014/07/30/trying-to-use-devstack/"><img src="md/images/metrying.gif" width="480" /></a>

---
<!-- .slide: data-transition="convex" -->

### 결국 테스트가 필요

<img src="md/images/2016-10-08_18-58-26.jpg" />

뭐 세상일이 쉽게 될리는.. 싶지만서도..

---
<!-- .slide: data-transition="convex" -->

### unit test

tox

<ul>
<span class="fragment"><li>라고 심플하게 적고 싶으나 사실은 인스톨 할정도의 패키지와 library 들이 미리 설치 되어 있어야 함</li></span>
<span class="fragment"><li>일반적으로 미리 .tox용 venv를 [캐슁](https://github.com/leoh0/tox-openstack-base-public) 해서 [빠르게](http://showterm.io/a99f79808c15d98f34cd3) 사용</li></span>
</ul>

---
<!-- .slide: data-transition="convex" -->

### integration test

tempest + (rally)

<ul>
<span class="fragment"><li>라고 심플하게 적고 싶으나 사실은 이게 제일 지옥임</li></span>
<span class="fragment"><li>왜냐하면 tempest, rally는 우선 stable branch가 없음</li></span>
<span class="fragment"><li>tempest의 config는 floating ip를 켰다는 전제하에 돌아가는 코드가 엄청나게 많음(그리고 이런류의 코드가 많음..)</li></span>
<span class="fragment"><li>아무튼 tempest를 자신의 환경에 맞추는 작업을 해야함</li></span>
<span class="fragment"><li>이것도 docker로 말아서 쓰고 있음</li></span>
</ul>

---
<!-- .slide: data-transition="convex" -->

### 테스트 성공.. ㅠㅠ

<img src="md/images/2016-09-23_00-40-50.jpg" width="640" />

이후엔 worker간 서로 테스트를 방해하는 케이스 때문에 그냥 concurrency=1 을 선택하게 됨..

---
<!-- .slide: data-transition="convex" -->

### 마지막으로.. 에러 관리

openstack에서 발생하는 error 로그를 <br/>처음으로 다 받아보게 된다면.. 아래와 같이..

<a href="https://openstackreactions.wordpress.com/2014/05/30/nova-xml-imp-looking/"><img src="md/images/trying-to-fix-xml-api.gif" width="840"></a>

---
<!-- .slide: data-transition="convex" -->

### log 기반 알림

* [ELK류](http://tech.kakao.com/2016/08/25/kemi/)로 전체 log에서 ERROR 로그만 수집해서 알림 받음
* 하지만 엄청난 양의 로그를 받을 수 있기 때문에 filtering등의 방법들이 필요
* 하지만 사실 동일한 에러라도 다양한 케이스 일 경우들이 많음

<img src="md/images/2016-10-08_20-23-24.jpg" />

---
<!-- .slide: data-transition="convex" -->

### openstack notification queue 기반 알림

* [stacktach](https://github.com/openstack/stacktach)로 notification.error 를 알림
* client error 등에도 빠르게 대응가능
* 이후에도 다양한 디버깅 용도로 사용가능 (event의 context가 자세하게 기록)

<img src="md/images/2016-10-08_20-25-11.jpg" />

---
<!-- .slide: data-transition="convex" -->

### Q & A

--

### inhouse openstack을 했던일중에 가장 큰 일에 대한 이야기를 한가지..

* 2015 3월 - 달리는기차의 엔진 갈아끼우기
 - openvswitch 에서 linux bridge 로 네트워크 <br />전체 무중단 교체
 - [당시 스크립트](https://gist.github.com/leoh0/eb8fee126563651f6c1bde813ed92619)

--

<img src="md/images/l2path변경1.jpg" />

--

<img src="md/images/l2path변경2.jpg" />

--

<img src="md/images/l2path변경3.jpg" />

--

<img src="md/images/l2path변경4.jpg" />

--

<img src="md/images/l2path변경5.jpg" />

--

<img src="md/images/l2path변경6.jpg" />

--

<img src="md/images/l2path변경7.jpg" />

---
<!-- .slide: data-transition="convex" -->

### 감사합니다.


