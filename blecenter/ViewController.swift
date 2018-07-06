//
//  ViewController.swift
//  blecenter
//
//  Created by JOSN on 2018/1/28.
//  Copyright © 2018年 JOSN. All rights reserved.
//

import UIKit
import CoreBluetooth
import AVFoundation
import AudioToolbox
import UserNotifications


class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    
    ///////////////////////////////////////////////////
    var soundplayer: AVAudioPlayer!
    ///////////////////////////////////////////////////
    
    ///////////////////////////////////////////////////
    enum SendDataError: Error {
        case CharacteristicNotFound
    }
    //GATT
//    let C001_CHARACTERISTIC = "FFE1"//"C001"
//    let C001_CHARACTERISTIC = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"//"C001"
//    let C001_CHARACTERISTIC_WRITE = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"//"C001"
    
    let BLEID_Nordic = "TYREDOG"
    let BLEID_Realtek = "Realtek"
    
    let CHAR_READ_Nordic = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"
    let CHAR_READ_Realtek = "FFE1"
    
    let CHAR_WRITE_Nordic = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
    let CHAR_WRITE_Realtek = "FFE1"
    
    var BLEID: [String] = []
    var CHARACTERISTIC_READ: [String] = []
    var CHARACTERISTIC_WRITE: [String] = []
    
    
    var CHAR_READ = ""
    var CHAR_WRITE = ""
    var centralManager: CBCentralManager!
    var connectPeripheral: CBPeripheral!
    var charDictionary = [String: CBCharacteristic] ()
    ///////////////////////////////////////////////////
    //Timer
    var timer1_ant: Timer!
    var timer2_rxflash: Timer!
    var timer3_sound: Timer!
    
    ///////////////////////////////////////////////////
    let TM10 = "[36, 65, 48, 49, 48"
    let TM11 = "[36, 65, 48, 49, 49"
    let TM120 = "[36, 65, 48, 49, 50, 48, 48"
    let TM121 = "[36, 65, 48, 49, 50, 48, 49"
    
    let TC20 = "[36, 65, 48, 65, 48"
    let TC210 = "[36, 65, 48, 65, 49, 48, 48"
    let TC211 = "[36, 65, 48, 65, 49, 48, 49"
    let TC22 = "[36, 65, 48, 65, 50, 48, 48"
    let TC23 = "[36, 65, 48, 65, 51, 48, 48"
    let TC240 = "[36, 65, 48, 65, 52, 48, 48"
    let TC241 = "[36, 65, 48, 65, 52, 48, 49"
    let TC25 = "[36, 65, 48, 65, 53, 48, 48"
    
    let TS30 = "[36, 65, 48, 51, 48"
    
    let TC40 = "[36, 65, 48, 67, 48, 48, 48"
    let TC41 = "[36, 65, 48, 67, 49, 48, 48"
    let TC42 = "[36, 65, 48, 67, 50"
    let TC43 = "[36, 65, 48, 67, 51, 48, 48"
    let TC44 = "[36, 65, 48, 67, 52"
    let TC45 = "[36, 65, 48, 67, 53, 48, 49"
    
    let TC50 = "[36, 65, 48, 68, 48, 48, 48"
    let TC510 = "[36, 65, 48, 68, 49, 48, 48"
    let TC511 = "[36, 65, 48, 68, 49, 48, 49"
    let TC512 = "[36, 65, 48, 68, 49, 48, 50"
    let TC513 = "[36, 65, 48, 68, 49, 48, 51"
    let TC52 = "[36, 65, 48, 68, 50, 48, 48"
    let TC53 = "[36, 65, 48, 68, 51, 48, 48"
    let TC540 = "[36, 65, 48, 68, 52, 48, 48"
    let TC541 = "[36, 65, 48, 53, 52, 48, 49"
    let TC542 = "[36, 65, 48, 53, 52, 48, 50"
    let TC543 = "[36, 65, 48, 53, 52, 48, 51"
    ///////////////////////////////////////////////////
    
    let TX_TC210 = "$A0210034#"
    let TX_TC211 = "$A0210135#"
    
    let TX_TC23  =  "$A0230036#"
    let TX_TC240 = "$A0240037#"
    let TX_TC241 = "$A0240138#"
    let TX_TC25  = "$A0250038#"
    
    let TX_TC40  = "$A0400035#"
    let TX_TC43  = "$A0430038#"
    let TX_TC45  = "$A045013B#"
    
    let TX_TC50  = "$A0500036#"
    
    let TX_TC540 = "$A054003A#"
    
    ///////////////////////////////////////////////////

    
    ///////////////////////////////////////////////////
    let PunitList = ["PSI", "KPA", "BAR", "Kg/cm2"]
    let TunitList = ["°C", "°F"]
    let AlarmsoundList = ["OFF", "ON"]
    let NotysoundList = ["OFF", "ON"]
    
    
    let Punit_k = [1, 6.895, 0.06895, 0.07031]
    let Tunit_k0 = 1.8
    let Tunit_k1 = 32
    let PressPoint = [1,0,2,2]
    let TempPoint = [0,0]
    
    var saveValue = ["FIRST":0,"PUNIT":0,"TUNIT":0,"HPLIMIT":45,"LPLIMIT":26,"HTLIMIT":70,"HPMAX":100,"LPMAX":100,"HTMAX":125,"W0":0,"W1":1,"W2":2,"W3":3,"W4":4,"W5":5,"SETFLAG":0,"CLOSE":0,"AlarmSound":1,"NotySound":1]
    var initValue = ["FIRST":1,"PUNIT":0,"TUNIT":0,"HPLIMIT":45,"LPLIMIT":26,"HTLIMIT":70,"HPMAX":100,"LPMAX":100,"HTMAX":125,"W0":0,"W1":1,"W2":2,"W3":3,"W4":4,"W5":5,"SETFLAG":0,"CLOSE":0,"AlarmSound":1,"NotySound":1]

    
    var wheel_total = 4
    var wheel = [0,1,2,3,4,5]
    var wheel_img_on = ["p_no_1_1","p_no_2_2","p_no_3_2","p_no_4_2","p_no_5_2","p_no_6_2"]
    var wheel_img_on_land = ["l_no_1_1","l_no_2_2","l_no_3_2","l_no_4_2","l_no_5_2","l_no_6_2"]
    var wheel_img_off = ["p_no_1_0","p_no_2_0","p_no_3_0","p_no_4_0","p_no_5_0","p_no_6_0"]
    var wheel_img_off_land = ["l_no_1_0","l_no_2_0","l_no_3_0","l_no_4_0","l_no_5_0","l_no_6_0"]
    
    var bt_img = ["p_sign_bt_0","p_sign_bt_1"]
    var bt_img_land = ["l_sign_bt_0","l_sign_bt_1"]
    var press_img = ["p_sign_press_0","p_sign_press_1","p_sign_press_2"]
    var press_img_land = ["l_sign_press_0","l_sign_press_1","l_sign_press_2"]
    var temp_img = ["p_sign_temp_0","p_sign_temp_1","p_sign_temp_2"]
    var temp_img_land = ["l_sign_temp_0","l_sign_temp_1","l_sign_temp_2"]
    
    var punit_img = ["p_unitp_psi_0","p_unitp_kpa_0","p_unitp_bar_0","p_unitp_kgcm_0"]
    var punit_img_land = ["l_unitp_psi_0","l_unitp_kpa_0","l_unitp_bar_0","l_unitp_kgcm_0"]
    var tunit_img = ["p_unitt_c_0","p_unitt_f_0"]
    var tunit_img_land = ["l_unitt_c_0","l_unitt_f_0"]
    
    var vplane_img = ["p_bg_value_0"]
    var vplane_img_land = ["l_bg_value_0"]
    
    var Flashant_cnt = 0
    var antbtn = ["p_sign_rx_0","p_sign_rx_1","p_sign_rx_2","p_sign_rx_3"]
    var antbtn_land = ["l_sign_rx_0","l_sign_rx_1","l_sign_rx_2","l_sign_rx_3"]
    
    
    
    
    
    
    
//    var wheelButton: [UIButton] = [self.btn_wheel0,self.btn_wheel0,self.btn_wheel0]
    var wheelButton: [UIButton] = [UIButton]()
    var btButton: [UIButton] = [UIButton]()
    var pressButton: [UIButton] = [UIButton]()
    var tempButton: [UIButton] = [UIButton]()
    var PvalueLabel: [UILabel] = [UILabel]()
    var TvalueLabel: [UILabel] = [UILabel]()
    var ImgValuePlane: [UIImageView] = [UIImageView]()
    
    var wheelbottom_Cst: [NSLayoutConstraint] = [NSLayoutConstraint]()
    var wheelbottom_Cst_Initial = [10, 10, 10, 10, 10, 10]
    
    
    
    
    var debug_flag: Bool? = false
    
    var IPAD_flag: Bool? = false
    var rxlog_flag: Bool? = false
    var screenPL: Bool? = true
    
    var view_voice_flag: Bool? = false
    var view_setting_flag: Bool? = false
    
    var flash_ant_flag: Bool? = false
    var CHwheel_flag: Bool? = false
    var flash_wheel_flag: Bool? = false
    var flash_wheel_up_flag: Bool? = false
    var jumpwheel = 0
    var rxupdate_falg: Bool? = false
    var flash_wheel_cnt = 0
    let flash_wheel_cnt_k = 10
    
    
    
    
    
    var RxdataBuf = ["", "", "", "", "", ""]
    let PressDataI: [Double] = [32.0, 32.5, 31.5, 32.0, 35.0, 36.0]
    let TempDataI: [Double] = [26, 25, 25, 24, 26, 27]
    var PressData: [Double] = [32.0, 32.0, 32.0, 32.0, 32.0, 32.0]
    var TempData = [25, 25, 25, 25, 25, 25]
    var PressDataS: [Double] = [32.0, 32.0, 32.0, 32.0, 32.0, 32.0]
    var TempDataS: [Double] = [25.0, 25.0, 25.0, 25.0, 25.0, 25.0]
    
    var RX_flag = [false, false, false, false, false, false]
    var BT_flag = [false, false, false, false, false, false]
    var PressHFlag = [false, false, false, false, false, false]
    var PressLFlag = [false, false, false, false, false, false]
    var TempHFlag = [false, false, false, false, false, false]
    var BtLowFlag = [false, false, false, false, false, false]

    var PressHRFlag = [false, false, false, false, false, false]
    var PressLRFlag = [false, false, false, false, false, false]
    var TempHRFlag = [false, false, false, false, false, false]
    
    let DeltaPress_k = 1
    let DeltaTemp_k = 1
    
    let HIGHPRESS = 0
    let LOWPRESS = 1
    let HIGHTEMP = 2
    let LOWBT = 3
    
    var alarmflag = false
    var alarmflag2 = false

    let alarmcnt_k = 0
    let alarmcnt_k1 = 10
    let alarmcnt_k2 = 15
    var alarm_cnt = 15
    
    let soundcnt_k = 10
    let soundcnt_k1 = 5
    var sound_cnt = 0
    
    var PressHigh: [Double] = [32.0, 32.0, 32.0, 32.0, 32.0, 32.0]
    var PressLow: [Double] = [32.0, 32.0, 32.0, 32.0, 32.0, 32.0]
    var TempHigh = [25, 25, 25, 25, 25, 25]
    var PressRHigh: [Double] = [32.0, 32.0, 32.0, 32.0, 32.0, 32.0]
    var PressRLow: [Double] = [32.0, 32.0, 32.0, 32.0, 32.0, 32.0]
    var TempRHigh = [25, 25, 25, 25, 25, 25]
    
    var FLASH_WHEEL = [false, false, false, false, false, false]
    
    
    var NotyAlarm_cnt = 0
    var notiyID = ""
    var settitle = ""
    var subtitle = ""
    var body = ""
    var cnt = 0
    var sound = ""
    var icon = ""
 
    
    var alarmwheel = ["wheelLF","wheelRF","wheelLR","wheelRR"]
    var alarmwheel6 = ["wheel0","wheel1","wheel2","wheel3","wheel4","wheel5"]
    var alarmtltle = ["pressalarm","pressalarm","tempalarm","sensoralarm"]
    var alarmtype0 = ["press","press","temp","sensor"]
    var alarmtype1 = ["pressH","pressL","tempH","btL"]
    var alarmsound_p = ["pfl.wav","pfr.wav","prl.wav","prr.wav"]
    var alarmsound_t = ["tfl.wav","tfr.wav","trl.wav","trr.wav"]
    var alarmsound_s = ["sfl.wav","sfr.wav","srl.wav","srr.wav"]
    var alarmicon = ["alarmw1","alarmw2","alarmw3","alarmw4"]
    var alarmicon6 = ["alarmw1","alarmw2","alarmw3","alarmw4","alarmw4","alarmw4"]
    
    
    var str: String? = nil
    
    
    
    @IBOutlet weak var sw_ble: UISwitch!
    @IBOutlet weak var btn_pair: UIButton!
    @IBOutlet weak var btn_repair: UIButton!
    @IBOutlet weak var btn_read: UIButton!
    
    
    @IBOutlet weak var txt_rx: UITextView!
    
    @IBOutlet weak var img_bg_main: UIImageView!
    @IBOutlet weak var btn_car: UIButton!
    @IBOutlet weak var btn_logo: UIButton!
    @IBOutlet weak var btn_status: UIButton!
    @IBOutlet weak var btn_voice: UIButton!
    @IBOutlet weak var btn_setting: UIButton!
    @IBOutlet weak var btn_about: UIButton!
    
    @IBOutlet weak var btn_ant: UIButton!
    @IBOutlet weak var btn_unitP: UIButton!
    @IBOutlet weak var btn_unitT: UIButton!
    
    @IBOutlet weak var btn_wheel0: UIButton!
    @IBOutlet weak var btn_wheel1: UIButton!
    @IBOutlet weak var btn_wheel2: UIButton!
    @IBOutlet weak var btn_wheel3: UIButton!
    @IBOutlet weak var btn_bt0: UIButton!
    @IBOutlet weak var btn_bt1: UIButton!
    @IBOutlet weak var btn_bt2: UIButton!
    @IBOutlet weak var btn_bt3: UIButton!
    @IBOutlet weak var btn_press0: UIButton!
    @IBOutlet weak var btn_press1: UIButton!
    @IBOutlet weak var btn_press2: UIButton!
    @IBOutlet weak var btn_press3: UIButton!
    @IBOutlet weak var btn_temp0: UIButton!
    @IBOutlet weak var btn_temp1: UIButton!
    @IBOutlet weak var btn_temp2: UIButton!
    @IBOutlet weak var btn_temp3: UIButton!
    
    @IBOutlet weak var lab_value_P0: UILabel!
    @IBOutlet weak var lab_value_P1: UILabel!
    @IBOutlet weak var lab_value_P2: UILabel!
    @IBOutlet weak var lab_value_P3: UILabel!
    @IBOutlet weak var lab_value_T0: UILabel!
    @IBOutlet weak var lab_value_T1: UILabel!
    @IBOutlet weak var lab_value_T2: UILabel!
    @IBOutlet weak var lab_value_T3: UILabel!
    
    @IBOutlet weak var Img_bg_value0: UIImageView!
    @IBOutlet weak var Img_bg_value1: UIImageView!
    @IBOutlet weak var Img_bg_value2: UIImageView!
    @IBOutlet weak var Img_bg_value3: UIImageView!
    
    
    @IBOutlet weak var btn_wheel0_bottomCst: NSLayoutConstraint!
    @IBOutlet weak var btn_wheel1_bottomCst: NSLayoutConstraint!
    @IBOutlet weak var btn_wheel2_bottomCst: NSLayoutConstraint!
    @IBOutlet weak var btn_wheel3_bottomCst: NSLayoutConstraint!
    
    
    @IBOutlet weak var view_setting: UIView!
    @IBOutlet weak var view_setting_bottomCst: NSLayoutConstraint!
    
    @IBOutlet weak var lab_title_Punit: UILabel!
    @IBOutlet weak var lab_title_Tunit: UILabel!
    @IBOutlet weak var lab_title_PHlimit: UILabel!
    @IBOutlet weak var lab_title_PLlimit: UILabel!
    @IBOutlet weak var lab_title_THlimit: UILabel!

    @IBOutlet weak var lab_value_PHlimit: UILabel!
    @IBOutlet weak var lab_value_PLlimit: UILabel!
    @IBOutlet weak var lab_value_THlimit: UILabel!
    @IBOutlet weak var pkr_value_Punit: UIPickerView!
    @IBOutlet weak var pkr_value_Tunit: UIPickerView!
    @IBOutlet weak var slr_setting_PHlimit: UISlider!
    @IBOutlet weak var slr_setting_PLlimit: UISlider!
    @IBOutlet weak var slr_setting_THlimit: UISlider!
    @IBOutlet weak var btn_setting_initial: UIButton!
    @IBOutlet weak var btn_setting_close: UIButton!
    
    
    @IBOutlet weak var view_voice: UIView!
    @IBOutlet weak var view_voice_bottomCst: NSLayoutConstraint!
    
    @IBOutlet weak var lab_value_alarmsound: UILabel!
    @IBOutlet weak var lab_value_notysound: UILabel!
    @IBOutlet weak var pkr_value_alarmsound: UIPickerView!
    @IBOutlet weak var pkr_value_notysound: UIPickerView!
    @IBOutlet weak var btn_voice_close: UIButton!
    
    
    @IBOutlet var view_about: UIView!
    @IBOutlet var viewEffect_about: UIVisualEffectView!
    @IBOutlet weak var btn_viewabout_exit: UIButton!
    @IBOutlet weak var txt_about: UITextView!
    
    
    
    
    
    
    @IBOutlet weak var btn_voice_land: UIButton!
    @IBOutlet weak var btn_setting_land: UIButton!
    
    
    
    
    
    
    @IBOutlet weak var windowslider: UISlider!
    @IBOutlet weak var lab_notiyslider: UILabel!
    @IBOutlet weak var lab_windowslider: UILabel!
    let userT = UserDefaults()
    @IBOutlet weak var labwsread: UILabel!
    @IBOutlet weak var labwsreadarray: UILabel!
    
    
    

    
    
    
////////////////////////////////////////////////////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        LogDebug(string: "viewDidLoad")
        
        UIApplication.shared.isIdleTimerDisabled = true

        Chaneg_view_port()
        

        
//        clearpara()
        checkpara()
        init_para()
        
//        init_display()

        
        timer_enable()
        ///////////////////////////////////////////////////
        let queue = DispatchQueue.global()
        centralManager = CBCentralManager(delegate: self, queue: queue)
        ///////////////////////////////////////////////////

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
////////////////////////////////////////////////////////////////////////////
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        LogDebug(string: "viewWillAppear")
        

        checkInterface()
        init_display()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        LogDebug(string: "viewDidAppear")
        
        

    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        LogDebug(string: "viewWillDisappear")
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        LogDebug(string: "viewDidDisappear")
    }
    
    
    
    
    func checkInterface() {
        statusOrientation()
        checkIPAD()
        
//        if IPAD_flag == true {
//            Chaneg_view_port()
//        }
    }
    
    
    
    
    
    
////////////////////////////////////////////////////////////////////////////
    func timer_enable() {
        Enable_Timer1()
        Enable_Timer2()
        Enable_Timer3()
    }
    func timer_disable() {
        Disable_Timer1()
        Disable_Timer2()
        Disable_Timer3()
//        Disable_Timer3()
//        Disable_Timer4()
    }
    func Enable_Timer1() {
        timer1_ant = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(Falsh_icon), userInfo: nil, repeats: true)
        LogDebug(string: "Enable_Timer1")
    }
    func Disable_Timer1() {
        if timer1_ant != nil {
            timer1_ant?.invalidate()
        }
    }
    func Enable_Timer2() -> Void {
        timer2_rxflash = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.Falsh_rx), userInfo: nil, repeats: true)
        LogDebug(string: "Enable_Timer2")
    }
    func Disable_Timer2() {
        if timer2_rxflash != nil {
            timer2_rxflash?.invalidate()
        }
    }
    func Enable_Timer3() -> Void {
        timer3_sound = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.sound_alarm), userInfo: nil, repeats: true)
        LogDebug(string: "Enable_Timer3")
    }
    func Disable_Timer3() {
        if timer3_sound != nil {
            timer3_sound?.invalidate()
        }
    }
////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
////////////////////////////////////////////////////////////////////////////
    func init_para(){
        BLEID = [BLEID_Nordic,BLEID_Nordic]
        CHARACTERISTIC_READ = [CHAR_READ_Nordic,CHAR_READ_Realtek]
        CHARACTERISTIC_WRITE = [CHAR_WRITE_Nordic,CHAR_WRITE_Realtek]
        
        
        wheelButton = [self.btn_wheel0,self.btn_wheel1,self.btn_wheel2,self.btn_wheel3]
        btButton = [self.btn_bt0,self.btn_bt1,self.btn_bt2,self.btn_bt3]
        pressButton = [self.btn_press0,self.btn_press1,self.btn_press2,self.btn_press3]
        tempButton = [self.btn_temp0,self.btn_temp1,self.btn_temp2,self.btn_temp3]
        PvalueLabel = [self.lab_value_P0,self.lab_value_P1,self.lab_value_P2,self.lab_value_P3]
        TvalueLabel = [self.lab_value_T0,self.lab_value_T1,self.lab_value_T2,self.lab_value_T3]
        ImgValuePlane = [self.Img_bg_value0,self.Img_bg_value1,self.Img_bg_value2,self.Img_bg_value3]
            
            
        wheelbottom_Cst = [self.btn_wheel0_bottomCst,self.btn_wheel1_bottomCst,self.btn_wheel2_bottomCst,self.btn_wheel3_bottomCst]
        
        
        
        SetBtn_longpress()
    }
////////////////////////////////////////////////////////////////////////////
    

    
    

    
    

////////////////////////////////////////////////////////////////////////////
    //NO.1
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central.state == .poweredOn else {
            return
        }
        
        //去除舊配對
        unpair_uuid()
        //偵測是否有已配對未連線
        if ispair() {
            //觸發3號 noscan 直接連結
            centralManager.connect(connectPeripheral, options: nil)
        } else {
            //觸發2號 scan function
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        } 
    }
////////////////////////////////////////////////////////////////////////////
    //NO.2
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber){
        
        LogDebug(string: "開始掃描")
        guard let deviceName = peripheral.name else {
            return
        }
        LogDebug(string: "找到藍牙裝置: \(deviceName)")
        guard deviceName.range(of: "TYREDOG") != nil || deviceName.range(of: "MacBook") != nil || deviceName.range(of: "Realtek") != nil
            else{
                return
        }
//        BLEID
        
        LogDebug(string: "停止掃描")
        central.stopScan()

        //儲存配對資訊
        let user = UserDefaults.standard
        user.set(peripheral.identifier.uuidString, forKey: "KEY_PERIPHERAL_UUID")
        user.synchronize()
        
        connectPeripheral = peripheral
        connectPeripheral.delegate = self
        
        centralManager.connect(connectPeripheral, options: nil)
    }
////////////////////////////////////////////////////////////////////////////
    //NO.3
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        charDictionary = [:]
        //觸發 NO.4
        LogDebug(string: "連線peripheral")
        peripheral.discoverServices(nil)
    }
////////////////////////////////////////////////////////////////////////////
    //NO.4
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        LogDebug(string: "掃描service")
        guard error == nil else {
            LogDebug(string: "Error: \(#file, #function)")
            LogDebug(string: error!.localizedDescription)
            return
        }
        for service in peripheral.services! {
            //觸發 NO.5
            connectPeripheral.discoverCharacteristics(nil, for: service)
        }
    }
////////////////////////////////////////////////////////////////////////////
    //NO.5
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        LogDebug(string: "掃描Characteristics")
        guard error == nil else {
            LogDebug(string: "Error: \(#file, #function)")
            LogDebug(string: error!.localizedDescription)
            return
        }
        for characteristic in service.characteristics! {
            let uuidString = characteristic.uuid.uuidString
            charDictionary[uuidString] = characteristic
//            print("找到: \(uuidString)")

            if Check_CHAR_READ(uuid: uuidString) == true {
                LogDebug(string: "UUID MATCH -> \(uuidString)")
                CHAR_READ = uuidString
                flash_ant_flag = true
                showToast(message: LS(text: "module_connected"))
                SetNotify(flag: true)
            }
            if Check_CHAR_WRITE(uuid: uuidString) == true {
                LogDebug(string: "UUID MATCH -> \(uuidString)")
                CHAR_WRITE = uuidString
                Enable_TYREDOG()
            }
        }
    }
////////////////////////////////////////////////////////////////////////////
    
    
    func SetNotify(flag: Bool) {
        connectPeripheral.setNotifyValue(flag, for: charDictionary[CHAR_READ]!)
    }

    
////////////////////////////////////////////////////////////////////////////
    func Check_CHAR_READ (uuid: String) -> Bool {
        for i in 0..<CHARACTERISTIC_READ.count {
            if uuid.range(of: CHARACTERISTIC_READ[i]) != nil {
                return true
            }
        }
        return false
    }
    func Check_CHAR_WRITE (uuid: String) -> Bool {
        for i in 0..<CHARACTERISTIC_WRITE.count {
            if uuid.range(of: CHARACTERISTIC_WRITE[i]) != nil {
                return true
            }
        }
        return false
    }
////////////////////////////////////////////////////////////////////////////
    //藍牙斷線
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        LogDebug(string: "連線中斷")
        flash_ant_flag = false
        ClrRxflag()
        showToast(message: LS(text: "module_disconnected"))
        if ispair() {
            //#3
            centralManager.connect(connectPeripheral, options: nil)
        }
    }
////////////////////////////////////////////////////////////////////////////
    
    
////////////////////////////////////////////////////////////////////////////
    func BleSend(message: String) {
        do {
            let data = message.data(using: .utf8)
            //            withResponse withoutResponse
            try sendData(data!, uuidString: CHAR_WRITE, writeType: .withoutResponse)
        } catch {
            print(error)
        }
    }
    //Send data to peripheral
    func sendData(_ data: Data, uuidString: String, writeType: CBCharacteristicWriteType) throws {
        guard let characteristic = charDictionary[uuidString] else {
            throw SendDataError.CharacteristicNotFound
            
        }
        connectPeripheral.writeValue(data, for: characteristic, type: writeType)
    }
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            LogDebug(string: "寫入資料錯誤: \(error!)")
        }
    }
////////////////////////////////////////////////////////////////////////////
    //Rxcevice data to peripheral
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            LogDebug(string: "ERROR: \(#file, #function)")
            print(error!)
            return
        }
        if characteristic.uuid.uuidString == CHAR_READ {
            let data = characteristic.value! as NSData
            let string = String(data: data as Data, encoding: .utf8)!
//            print(string)
//            NSLog(string)
//            LogDebug(string: string)  //$1015100890#
//            print(Array(string))      //["$", ..., #]
            DispatchQueue.main.async {
                self.txt_rx.text = string
            }
            
            let str: [UInt8] = [UInt8](string.utf8)
//            print (str)         //this is array [24,...,23]  is unit8
//            print(str.count)  //array size
//            if str[0] == 0x24 {
//                LogDebug(string: string)
//            }
            
            let str_data = "\(str)"            // array to string "[24, ..., 23]"
            let array_data = Array(string)     // array to string "["$", ..., "#"] string element
//            LogDebug(string: str_data)
            

            //new protocol
            if ((str_data.contains(TM10)) || (str_data.contains(TM11))) == true {
                //                LogDebug(string: string)  //$1015100890#
                if ((str[0] == 0x24) && (str[15] == 0x23)) == true {
                    var chksumbuf: Int = 0
                    for index in 1...(str.count-4) {
                        chksumbuf = (ascii2dec(num: String(array_data[index])) + (chksumbuf & 0xff))
                    }
                    var rxchk0 = 0
                    var rxchk1 = 0
                    
                    if ((str[13] >= 65) && (str[13] <= 70)) == true {
                        rxchk1 = Int(str[13] - 65 + 10)
                    } else if ((str[13] >= 48) && (str[13] <= 57)) == true {
                        rxchk1 = Int(str[13] - 48)
                    } else {
                    }
                    if ((str[14] >= 65) && (str[14] <= 70)) == true {
                        rxchk0 = Int(str[14] - 65 + 10)
                    } else if ((str[14] >= 48) && (str[14] <= 57)) == true {
                        rxchk0 = Int(str[14] - 48)
                    } else {
                    }
                    let chksum = rxchk1 * 16 + rxchk0
                    
                    if chksum == chksumbuf {
                        //                        LogDebug(string: "Match chksum !")
                        
                        if rxupdate_falg == false {
                            if chkdata(wheel: Int(str[6]),data: string) == true {
                                LogDebug(string: "NEW DATA")
                                rxupdate_falg = true
                                
                                var wheel_N = 0
                                switch Int(str[6]) {
                                case 0x30:
                                    wheel_N = 0
                                case 0x31:
                                    wheel_N = 1
                                case 0x32:
                                    wheel_N = 2
                                case 0x33:
                                    wheel_N = 3
                                case 0x34:
                                    wheel_N = 4
                                case 0x35:
                                    wheel_N = 5
                                default:
                                    wheel_N = 0
                                }
                                
                                var wbt = false
                                if byte2toFlag(Byte1: Int(str[7]),Byte0: Int(str[8]),Bit: 1) == true {
                                    wbt = true
                                }
                                var wrx = false
                                if byte2toFlag(Byte1: Int(str[7]),Byte0: Int(str[8]),Bit: 7) == true {
                                    wrx = true
                                }
                                var wpt = false
                                if byte2toFlag(Byte1: Int(str[7]),Byte0: Int(str[8]),Bit: 0) == true {
                                    wpt = true
                                }
                                
                                var press0 = 0
                                var press1 = 0
                                if ((str[9] >= 65) && (str[9] <= 70)) == true {
                                    press1 = Int(str[9] - 65 + 10)
                                } else if ((str[9] >= 48) && (str[9] <= 57)) == true {
                                    press1 = Int(str[9] - 48)
                                } else {
                                }
                                if ((str[10] >= 65) && (str[10] <= 70)) == true {
                                    press0 = Int(str[10] - 65 + 10)
                                } else if ((str[10] >= 48) && (str[10] <= 57)) == true {
                                    press0 = Int(str[10] - 48)
                                } else {
                                }
                                let press = press1 * 16 + press0
                                var pressure: Double = 0
                                if wpt == true {
                                    pressure = Double(press) + 0.5
                                } else {
                                    pressure = Double(press) + 0.0
                                }
                                
                                
                                var temp0 = 0
                                var temp1 = 0
                                if ((str[11] >= 65) && (str[11] <= 70)) == true {
                                    temp1 = Int(str[11] - 65 + 10)
                                } else if ((str[11] >= 48) && (str[11] <= 57)) == true {
                                    temp1 = Int(str[11] - 48)
                                } else {
                                }
                                if ((str[12] >= 65) && (str[12] <= 70)) == true {
                                    temp0 = Int(str[12] - 65 + 10)
                                } else if ((str[12] >= 48) && (str[12] <= 57)) == true {
                                    temp0 = Int(str[12] - 48)
                                } else {
                                }
                                let temp = ((temp1 * 16 + temp0) - 40)
                                
                                PressData[wheel_N] = pressure
                                TempData[wheel_N] = temp
                                RX_flag[wheel_N] = wrx
                                BT_flag[wheel_N] = wbt
                                
                                checkdata(i: wheel_N)
                            }
                        }
                    }
                }
                
                
            } else if str_data.contains(TM120) {
            } else if str_data.contains(TM121) {
                ClrRxflag()
            } else if str_data.contains(TC20) {
            } else if str_data.contains(TC210) {
            } else if str_data.contains(TC211) {
                ClrRxflag()
            } else if str_data.contains(TC22) {
            } else if str_data.contains(TC23) {
            } else if str_data.contains(TC240) {
            } else if str_data.contains(TC241) {
            } else if str_data.contains(TC25) {
            } else if str_data.contains(TS30) {
            } else if str_data.contains(TC41) {
            } else if str_data.contains(TC42) {
            } else if str_data.contains(TC43) {
            } else if str_data.contains(TC44) {
            } else if str_data.contains(TC45) {
                ClrRxflag()
            } else if str_data.contains(TC50) {
            } else if str_data.contains(TC510) {
            } else if str_data.contains(TC511) {
            } else if str_data.contains(TC512) {
            } else if str_data.contains(TC513) {
            } else if str_data.contains(TC52) {
            } else if str_data.contains(TC53) {
            } else if str_data.contains(TC540) {
            } else if str_data.contains(TC541) {
            } else if str_data.contains(TC542) {
            } else if str_data.contains(TC543) {
            } else {
            }
            
            //old protocol
            if str.count == 12 {
//                LogDebug(string: string)  //$1015100890#
                if ((str[0] == 0x24) && (str[11] == 0x23)) == true {
                    var chksumbuf: Int = 0
                    for index in 1...(str.count-4) {
                        chksumbuf = (ascii2dec(num: String(array_data[index])) + (chksumbuf & 0xff))
                    }
                    var rxchk0 = 0
                    var rxchk1 = 0
                    
                    if ((str[9] >= 65) && (str[9] <= 70)) == true {
                        rxchk1 = Int(str[9] - 65 + 10)
                    } else if ((str[9] >= 48) && (str[9] <= 57)) == true {
                        rxchk1 = Int(str[9] - 48)
                    } else {
                    }
                    if ((str[10] >= 65) && (str[10] <= 70)) == true {
                        rxchk0 = Int(str[10] - 65 + 10)
                    } else if ((str[10] >= 48) && (str[10] <= 57)) == true {
                        rxchk0 = Int(str[10] - 48)
                    } else {
                    }
                    let chksum = rxchk1 * 16 + rxchk0
                    
                    if chksum == chksumbuf {
//                        LogDebug(string: "Match chksum !")
                        
                        if rxupdate_falg == false {
                            if chkdata(wheel: Int(str[1]),data: string) == true {
                                LogDebug(string: "NEW DATA")
                                rxupdate_falg = true
                                
                                var wheel_N = 0
                                switch Int(str[1]) {
                                case 0x30:
                                    wheel_N = 0
                                case 0x31:
                                    wheel_N = 1
                                case 0x32:
                                    wheel_N = 2
                                case 0x33:
                                    wheel_N = 3
                                case 0x34:
                                    wheel_N = 4
                                case 0x35:
                                    wheel_N = 5
                                default:
                                    wheel_N = 0
                                }
                                
                                var wbt = false
                                if str[2] == 0x31 {
                                    wbt = true
                                }
                                var wrx = false
                                if str[3] == 0x31 {
                                    wrx = true
                                }
                                var wpt = false
                                if str[4] == 0x35 {
                                    wpt = true
                                }
                                
                                var press0 = 0
                                var press1 = 0
                                if ((str[5] >= 65) && (str[5] <= 70)) == true {
                                    press1 = Int(str[5] - 65 + 10)
                                } else if ((str[5] >= 48) && (str[5] <= 57)) == true {
                                    press1 = Int(str[5] - 48)
                                } else {
                                }
                                if ((str[6] >= 65) && (str[6] <= 70)) == true {
                                    press0 = Int(str[6] - 65 + 10)
                                } else if ((str[6] >= 48) && (str[6] <= 57)) == true {
                                    press0 = Int(str[6] - 48)
                                } else {
                                }
                                let press = press1 * 16 + press0
                                var pressure: Double = 0
                                if wpt == true {
                                    pressure = Double(press) + 0.5
                                } else {
                                    pressure = Double(press) + 0.0
                                }
                                
                                
                                var temp0 = 0
                                var temp1 = 0
                                if ((str[7] >= 65) && (str[7] <= 70)) == true {
                                    temp1 = Int(str[7] - 65 + 10)
                                } else if ((str[7] >= 48) && (str[7] <= 57)) == true {
                                    temp1 = Int(str[7] - 48)
                                } else {
                                }
                                if ((str[8] >= 65) && (str[8] <= 70)) == true {
                                    temp0 = Int(str[8] - 65 + 10)
                                } else if ((str[8] >= 48) && (str[8] <= 57)) == true {
                                    temp0 = Int(str[8] - 48)
                                } else {
                                }
                                let temp = ((temp1 * 16 + temp0) - 40)
                            
                                PressData[wheel_N] = pressure
                                TempData[wheel_N] = temp
                                RX_flag[wheel_N] = wrx
                                BT_flag[wheel_N] = wbt
                                
                                checkdata(i: wheel_N)
                            }
                        }
                    }
                }
            }
        }
    }
////////////////////////////////////////////////////////////////////////////

    func ClrRxflag() {
        for i in 0..<wheel_total {
            RX_flag[i] = false
            RxdataBuf[i] = ""
            PressHFlag[i] = false
            PressLFlag[i] = false
            TempHFlag[i] = false
            BtLowFlag[i] = false
            PressHRFlag[i] = false
            PressLRFlag[i] = false
            TempHRFlag[i] = false
        }
        Enable_FlashValue()
    }
    
////////////////////////////////////////////////////////////////////////////
    func dec2hex(num: Int) -> String {
        return String(format: "%0x", num)
    }
    func ascii2dec(num: String) ->Int {
        return Int(UnicodeScalar(num)?.value ?? 48)
    }
    func byte2toFlag(Byte1: Int , Byte0: Int, Bit: Int) -> Bool {
        var Byte3 = 0
        var Byte2 = 0
        if Byte1 >= 65 {
            Byte3 = Byte1 - 55
        } else {
            Byte3 = Byte1 - 48
        }
        if Byte0 >= 65 {
            Byte2 = Byte0 - 55
        } else {
            Byte2 = Byte0 - 48
        }
        Byte2 = (Byte3 * 16) + Byte2
        for _ in 0...Bit {
//            LogDebug(string: "Bit:\(i)")
            Byte3 = Byte2 % 2
            Byte2 = Byte2 / 2
        }
        if Byte3 == 1 {
            return true
        } else {
            return false
        }
    }
    func chkdata(wheel: Int, data: String) -> Bool {
        let index = wheel - 48
        if RxdataBuf[index] == data {
            return false
        }
        RxdataBuf[index] = data
        return true
    }
////////////////////////////////////////////////////////////////////////////
    
    
    
////////////////////////////////////////////////////////////////////////////
    func checkdata(i: Int) {
        let Waddress = Check_wheel(wheelN: i)
//        let Waddress = i
        
        if RX_flag[i] ==  true {
            //PRESSURE
            if PressHFlag[i] == true {
                if PressData[i] > PressHigh[i] {
                    PressHigh[i] = PressData[i]
                    PressRHigh[i] = PressData[i]
                    alarm_cnt = alarmcnt_k
                    sound_cnt = 0
                    ShowNoty_Alarm(wheel: Waddress,type: 0)
                    PressHRFlag[i] = false
                } else {
                    if (PressData[i] < PressHigh[i]) && (PressData[i] >= Double(saveValue["HPLIMIT"]!)) == true {
                        if PressData[i] < PressRHigh[i] {
                            PressHRFlag[i] = true
                       } else if PressData[i] > PressRHigh[i] {
                            PressHRFlag[i] = false
                        } else {
                            
                        }
                        PressRHigh[i] = PressData[i]
                    } else if PressData[i] < Double(saveValue["HPLIMIT"]! - DeltaPress_k) {
                        PressHRFlag[i] = false
                        PressHFlag[i] = false
                    } else {
                    }
                }
            } else if PressLFlag[i] == true {
                if PressData[i] < PressLow[i] {
                    PressLow[i] = PressData[i]
                    PressRLow[i] = PressData[i]
                    alarm_cnt = alarmcnt_k
                    sound_cnt = 0
                    ShowNoty_Alarm(wheel: Waddress,type: 1)
                    PressLRFlag[i] = false
                } else {
                    if (PressData[i] > PressLow[i]) && (PressData[i] < Double(saveValue["LPLIMIT"]!)) == true {
                        if PressData[i] > PressRLow[i] {
                            PressLRFlag[i] = true
                        } else if PressData[i] < PressRLow[i] {
                            PressLRFlag[i] = false
                        } else {
                            
                        }
                        PressRLow[i] = PressData[i]
                    } else if PressData[i] > Double(saveValue["LPLIMIT"]! + DeltaPress_k) {
                        PressLRFlag[i] = false
                        PressLFlag[i] = false
                    } else {
                    }
                }
            } else {
                if PressData[i] >= Double(saveValue["HPLIMIT"]!) {
                    PressHFlag[i] = true
                    PressHigh[i] = PressData[i]
                    alarm_cnt = alarmcnt_k
                    sound_cnt = 0
                    ShowNoty_Alarm(wheel: Waddress,type: 0)
                } else if PressData[i] < Double(saveValue["LPLIMIT"]!) {
                    PressLFlag[i] = true
                    PressLow[i] = PressData[i]
                    alarm_cnt = alarmcnt_k
                    sound_cnt = 0
                    ShowNoty_Alarm(wheel: Waddress,type: 1)
                } else {
                    PressHFlag[i] = false
                    PressLFlag[i] = false
                }
            }
            //TEMPERTURE
            if TempHFlag[i] == true {
                if TempData[i] > TempHigh[i] {
                    TempHigh[i] = TempData[i]
                    TempRHigh[i] = TempData[i]
                    alarm_cnt = alarmcnt_k
                    sound_cnt = 0
                    ShowNoty_Alarm(wheel: Waddress,type: 2)
                    TempHRFlag[i] = false
                } else {
                    if TempData[i] < TempHigh[i] && (TempData[i] >= (saveValue["HTLIMIT"]!)) == true {
                        if TempData[i] < TempRHigh[i] {
                            TempHRFlag[i] = true
                        } else if TempData[i] > TempRHigh[i] {
                            TempHRFlag[i] = false
                        } else {
                            
                        }
                        TempRHigh[i] = TempData[i]
                    } else if TempData[i] < ((saveValue["HTLIMIT"]!) - DeltaTemp_k) {
                        TempHRFlag[i] = false
                        TempHFlag[i] = false
                    } else {
                        
                    }
                }
            } else {
                if TempData[i] >= (saveValue["HTLIMIT"]!) {
                    TempHFlag[i] = true
                    TempHigh[i] = TempData[i]
                    alarm_cnt = alarmcnt_k
                    sound_cnt = 0
                    ShowNoty_Alarm(wheel: Waddress,type: 2)
                } else {
                    TempHFlag[i] = false
                }
            }
            //BT
            if BtLowFlag[i] == true {
                if BT_flag[i] == true {
                    BtLowFlag[i] = true
                } else {
                    BtLowFlag[i] = false
                }
            } else {
                if BT_flag[i] == true {
                    BtLowFlag[i] = true
                    alarm_cnt = alarmcnt_k
                    sound_cnt = 0
                    ShowNoty_Alarm(wheel: Waddress,type: 3)
                } else {
                    BtLowFlag[i] = false
                }
            }

        } else if RX_flag[i] == false {
            PressHFlag[i] = false
            PressLFlag[i] = false
            TempHFlag[i] = false
        } else {
        }
        let changei = Check_wheel(wheelN: i)
        FLASH_WHEEL[changei] = true
    }
    ////////////////////////////////////////////////
    func Check_wheel(wheelN: Int) -> Int {
        var num = 0
        for i in 0...(wheel.count - 1) {
            if wheel[i] == wheelN {
                num = i
            }
        }
        return num
    }
////////////////////////////////////////////////////////////////////////////
    
    
    
////////////////////////////////////////////////////////////////////////////
    func checkalarm() {
        alarmflag = false
        for i in 0..<wheel_total {
            if ((PressHFlag[i] == true) || (PressLFlag[i] == true) || (TempHFlag[i] == true) || (BtLowFlag[i] == true)) == true {
                alarmflag = true
            }
        }
        if alarmflag2 == true {
            if alarmflag == true {
                
            } else {
                alarmflag2 = false
            }
        } else {
            if alarmflag == true {
                alarmflag2 = true
                LogDebug(string: "alarmflag2")
            } else {
                
            }
        }
    }
////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    
    
    
    
    
    
    //訂閱
    @IBAction func subscribeValue(_ sender: UISwitch) {
//        connectPeripheral.setNotifyValue(sender.isOn, for: charDictionary[CHAR_READ]!)
        SetNotify(flag: sender.isOn)
    }
    
    //直接開通知
    @IBAction func readDATAClick(_ sender: Any) {
//        let characteristic = charDictionary[CHAR_READ]!
//        connectPeripheral.readValue(for: characteristic)

        Enable_TYREDOG()
    }

    @IBAction func gopair(_ sender: Any) {
        enpair()
    }
    
    @IBAction func repair(_ sender: Any) {
        unpair()
    }
    
    //確認是否有已配對但未連線
    func ispair() -> Bool {
        let user = UserDefaults.standard
        if let uuidSrting = user.string(forKey: "KEY_PERIPHERAL_UUID") {
            let uuid = UUID(uuidString: uuidSrting)
            let list = centralManager.retrievePeripherals(withIdentifiers: [uuid!])
            if list.count > 0 {
                connectPeripheral = list.first!
                connectPeripheral.delegate = self
                print("已有配對但未連線裝置")
                return true
            }
        }
        return false
    }

    //解配對舊資料
    func unpair_uuid() {
        let user = UserDefaults.standard
        user.removeObject(forKey: "KEY_PERIPHERAL_UUID")
        user.synchronize()
//        centralManager.cancelPeripheralConnection(connectPeripheral)
    }
    //解配對
    func unpair() {
        let user = UserDefaults.standard
        user.removeObject(forKey: "KEY_PERIPHERAL_UUID")
        user.synchronize()
        centralManager.cancelPeripheralConnection(connectPeripheral)
    }
    //主動配對
    func enpair() {
        if ispair() {
            centralManager.connect(connectPeripheral, options: nil)
        } else {
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    

    //關閉鍵盤
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.3) {
            self.view.endEditing(true)
        }
    }
    
    
    
    
    
    func checkIPAD() {
            IPAD_flag = false
        if detect_userInterface() == "Ipad" {
            IPAD_flag = true
        }
    }
    
    
    func detect_userInterface() -> String {
        switch self.traitCollection.userInterfaceIdiom {
        case UIUserInterfaceIdiom.pad:
            LogDebug(string: "Ipad")
            return "Ipad"
        case UIUserInterfaceIdiom.phone:
            LogDebug(string: "Iphone")
            return "Iphone"
        case UIUserInterfaceIdiom.tv:
            LogDebug(string: "Apple TV")
            return "Apple TV"
        case UIUserInterfaceIdiom.carPlay:
            LogDebug(string: "Car TV")
            return "Car TV"
        case .unspecified:
            LogDebug(string: "unspecified")
            return "none"
        }
    }
    
    
    
    
    //偵測RC
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        if newCollection.horizontalSizeClass == .compact {
            print("WC")
        }
        else if (newCollection.horizontalSizeClass == .regular){
            print("WR")
        }
        if newCollection.verticalSizeClass == .compact {
            print("HC")
        }
        else if (newCollection.verticalSizeClass == .regular){
            print("HR")
        }
    }
    //螢幕方向
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        switch UIDevice.current.orientation {
        case .faceDown:
            LogDebug(string: "裝置面朝下")
        case .faceUp:
            LogDebug(string: "裝置面朝上")
        case .landscapeLeft:
            LogDebug(string: "裝置橫向 HOME在右邊")
            checkLP(Orenition: "land")
        case .landscapeRight:
            LogDebug(string: "裝置橫向 HOME在左邊")
            checkLP(Orenition: "land")
        case .portrait:
            LogDebug(string: "裝置直向")
            checkLP(Orenition: "port")
        case .portraitUpsideDown:
            LogDebug(string: "裝置上下顛倒")
            checkLP(Orenition: "port")
        case .unknown:
            LogDebug(string: "無法判定")
        }
        LogDebug(string: "解析度為 \(size.width) x \(size.height)")
    }
    
    
    func checkLP(Orenition: String) {
        if Orenition == "port" {
            screenPL = true
        } else {
            screenPL = false
        }
        if IPAD_flag == true {
//            updataIcon()
        }
    }
    
    
    func statusOrientation() {
        let status: UIInterfaceOrientation = UIApplication.shared.statusBarOrientation
        switch status {
        case .landscapeLeft:
            LogDebug(string: "landscapeLeft")
            checkLP(Orenition: "land")
        case .landscapeRight:
            LogDebug(string: "landscapeLeft")
            checkLP(Orenition: "land")
        case .portrait:
            LogDebug(string: "portrait")
            checkLP(Orenition: "port")
        case .portraitUpsideDown:
            LogDebug(string: "portraitUpsideDown")
            checkLP(Orenition: "port")
        case .unknown:
            LogDebug(string: "unknown")
            checkLP(Orenition: "port")
        }
    }
    
    
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if IPAD_flag == true {
            return .portrait
        } else {
            return UIInterfaceOrientationMask.all
        }

    }
    override var shouldAutorotate: Bool{
        if IPAD_flag == true {
            return false
        } else {
            return true
        }
    }
    
    
    
    func Chaneg_view_land() {
        let value = UIInterfaceOrientation.landscapeRight.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    func Chaneg_view_port() {
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    
    
////////////////////////////////////////////////////////////////////////////
    func init_display() {
        
        if debug_flag == true {
            rxlog_flag = true
            txt_rx.isHidden = false
        } else {
            rxlog_flag = false
            txt_rx.isHidden = true
            sw_ble.isHidden = true
            btn_pair.isHidden = true
            btn_repair.isHidden = true
            btn_read.isHidden = true
        }
//        updataIcon()
        

        display_allI()
        
        display_setting()
        display_voice()
    }
////////////////////////////////////////////////////////////////////////////
    
    
    
    func updataIcon() {
        if IPAD_flag == true {
            if screenPL == true {
                btn_voice_land.isHidden = true
                btn_setting_land.isHidden = true
            } else {
                btn_car.isHidden = true
                btn_status.isHidden = true
                btn_voice.isHidden = true
                btn_setting.isHidden = true
                btn_about.isHidden = true
            }
        }
    }
    
    
    
    
    
    func display_valuePlane() {

        for i in 0..<wheel_total {
            if screenPL == true {
                ImgViewImageChange(sender: ImgValuePlane[i],image: vplane_img[0])
            } else {
                ImgViewImageChange(sender: ImgValuePlane[i],image: vplane_img_land[0])
            }
        }
    }
    
    
    
    func display_unitP() {
        if screenPL == true {
            btnImageChange(sender: btn_unitP,image: punit_img[(saveValue["PUNIT"])!])
        } else {
            btnImageChange(sender: btn_unitP,image: punit_img_land[(saveValue["PUNIT"])!])
        }
    }
    func display_unitT() {
        if screenPL == true {
            btnImageChange(sender: btn_unitT,image: tunit_img[(saveValue["TUNIT"])!])
        } else {
            btnImageChange(sender: btn_unitT,image: tunit_img_land[(saveValue["TUNIT"])!])
        }
    }
    
    func display_btI() {
        loadwheel()
        for i in 0..<wheel_total {
            btnImageChange(sender: btButton[wheel[i]],image: load_btimage(status: false))
        }
    }
        
    
    func display_wheelI() {
        loadwheel()
        for i in 0..<wheel_total {
//            btnImageChange(sender: btn_wheel0,image: load_wheelimage(wheel: wheel[i]))
//            btnImageChange(sender: wheelButton[wheel[i]],image: load_wheelimage(wheel: i))
            btnImageChange(sender: wheelButton[i],image: load_wheelimage_off(wheel: wheel[i]))
        }
    }
    
    func load_wheelimage_on(wheel: Int) -> String {
        if screenPL == true {
            return wheel_img_on[wheel]
        } else {
            return wheel_img_on_land[wheel]
        }
    }
    func load_wheelimage_off(wheel: Int) -> String {
        if screenPL == true {
            return wheel_img_off[wheel]
        } else {
            return wheel_img_off_land[wheel]
        }
    }
    func loadwheel() {
        wheel[0] = (saveValue["W0"])!
        wheel[1] = (saveValue["W1"])!
        wheel[2] = (saveValue["W2"])!
        wheel[3] = (saveValue["W3"])!
        wheel[4] = (saveValue["W4"])!
        wheel[5] = (saveValue["W5"])!
    }

    
    
    func load_btimage(status: Bool) -> String {
        var index = 0
        if status == true {
            index = 1
        }
        if screenPL == true {
            return bt_img[index]
        } else {
            return bt_img_land[index]
        }
    }

    func load_pressimage(status: String) -> String {
        var index = 0
        if status == "HIGH" {
            index = 2
        } else if status == "LOW" {
            index = 2
        } else if status == "NORMAL" {
            index = 1
        } else {
        }
        if screenPL == true {
            return press_img[index]
        } else {
            return press_img_land[index]
        }
    }
    
    func load_tempimage(status: String) -> String {
        var index = 0
        if status == "HIGH" {
            index = 2
        } else if status == "LOW" {
            index = 2
        } else if status == "NORMAL" {
            index = 1
        } else {
        }
        if screenPL == true {
            return temp_img[index]
        } else {
            return temp_img_land[index]
        }
    }
////////////////////////////////////////////////////////////////////////////
    
    
    
    
////////////////////////////////////////////////////////////////////////////
    func display_valueI() {
        loadwheel()
        for i in 0..<wheel_total {
            PressData[i] = PressDataI[i]
            TempData[i] = Int(TempDataI[i])
            SetLabColor(sender: PvalueLabel[i], color: UIColor.white)
            SetLabColor(sender: TvalueLabel[i], color: UIColor.white)
        }
        Enable_FlashValue()
    }
////////////////////////////////////////////////////////////////////////////
    func Enable_FlashValue() {
        for i in 0..<wheel_total {
            FLASH_WHEEL[i] = true
        }
        rxupdate_falg = true
    }
////////////////////////////////////////////////////////////////////////////
    func display_all() {
        display_unitP()
        display_unitT()
        Enable_FlashValue()
    }
    func display_allI() {
        display_unitP()
        display_unitT()
        display_valueI()
        display_wheelI()
        display_btI()
    }
////////////////////////////////////////////////////////////////////////////
    
    
    
////////////////////////////////////////////////////////////////////////////
    func display_voice() {
        loadstr_voice()
        load_pkr_voice()
    }
    ////////////////////////////////////////////////
    func loadstr_voice() {
        lab_value_alarmsound.text = LS(text: "Title_alarmsound")
        lab_value_notysound.text = LS(text: "Title_notysound")
        SetBtnTitle(sender: btn_voice_close,text: LS(text: "Close"))
    }
    ////////////////////////////////////////////////
    func load_pkr_voice() {
        pkr_value_alarmsound.selectRow(saveValue["AlarmSound"]!, inComponent: 0, animated: true)
        pkr_value_notysound.selectRow(saveValue["NotySound"]!, inComponent: 0, animated: true)
    }
////////////////////////////////////////////////////////////////////////////
    func display_setting() {
        loadstr_setting()
        load_pkr_unit()
        load_limit_value()
    }
    ////////////////////////////////////////////////
    func loadstr_setting() {
        lab_title_Punit.text = LS(text: "Title_P_Unit")
        lab_title_Tunit.text = LS(text: "Title_T_Unit")
        lab_title_PHlimit.text = LS(text: "Title_PH")
        lab_title_PLlimit.text = LS(text: "Title_PL")
        lab_title_THlimit.text = LS(text: "Title_TH")
        SetBtnTitle(sender: btn_setting_initial,text: LS(text: "Initial"))
        SetBtnTitle(sender: btn_setting_close,text: LS(text: "Close"))
    }
    ////////////////////////////////////////////////
    func load_pkr_unit() {
        pkr_value_Punit.selectRow(saveValue["PUNIT"]!, inComponent: 0, animated: true)
        pkr_value_Tunit.selectRow(saveValue["TUNIT"]!, inComponent: 0, animated: true)
    }
    ////////////////////////////////////////////////
    func load_limit_value() {
        load_limit_PH()
        load_limit_PL()
        load_limit_TH()
    }
    ////////////////////////////////////////////////
    func load_limit_PH() {
        slr_setting_PHlimit.setValue(Float(saveValue["HPLIMIT"]!), animated: true)
        
        let value = PutPointN(value: Double(saveValue["HPLIMIT"]!) * Punit_k[(saveValue["PUNIT"])!],bit: PressPoint[(saveValue["PUNIT"])!])
        lab_value_PHlimit.text = String(value)
    }
    func load_limit_PL() {
        slr_setting_PLlimit.setValue(Float(saveValue["LPLIMIT"]!), animated: true)
        
        let value = PutPointN(value: Double(saveValue["LPLIMIT"]!) * Punit_k[(saveValue["PUNIT"])!],bit: PressPoint[(saveValue["PUNIT"])!])
//        LogDebug(string: String(value))
        lab_value_PLlimit.text = String(value)
    }
    func load_limit_TH() {
        slr_setting_THlimit.setValue(Float(saveValue["HTLIMIT"]!), animated: true)

        var value = Double(saveValue["HTLIMIT"]!)
        if (saveValue["TUNIT"])! == 1 {
            value = PutPointN(value: (Double(saveValue["HTLIMIT"]!) * Tunit_k0) + Double(Tunit_k1), bit: PressPoint[(saveValue["TUNIT"])!])
        } else {
            value = PutPointN(value: Double(saveValue["HTLIMIT"]!), bit: PressPoint[(saveValue["TUNIT"])!])
        }
        lab_value_THlimit.text = String(value)
    }
////////////////////////////////////////////////////////////////////////////
    
    

    
////////////////////////////////////////////////////////////////////////////
    func initial_limit() {
        saveValue["PUNIT"] = initValue["PUNIT"]
        saveValue["TUNIT"] = initValue["TUNIT"]
        saveValue["HPLIMIT"] = initValue["HPLIMIT"]
        saveValue["LPLIMIT"] = initValue["LPLIMIT"]
        saveValue["HTLIMIT"] = initValue["HTLIMIT"]
        savepara()
    }
    
    
    
    
    
    
    
////////////////////////////////////////////////////////////////////////////
    func checkpara() {
        let userT = UserDefaults()
        var value: Int = 0
        
        if let value_str: String = (userT.string(forKey: "FIRST")) {
            value = Int(value_str)!
        } else {
            value = 0
        }

        if value == 1 {
            loadpara()
        } else {
            savepara_init()
        }

    }
////////////////////////////////////////////////////////////////////////////
    func loadpara() {
        let userT = UserDefaults()
        for (key, value) in saveValue {
        LogDebug(string: ("\(key):\(value)"))
            let para: Int = Int(userT.string(forKey: key)!)!
        saveValue[key] = para
        }
        LogDebug(string: "loadpara")
    }
    ////////////////////////////////////////////////
    func clearpara() {
        let userT = UserDefaults()
        userT.removeObject(forKey: "FIRST")
        userT.synchronize()
        LogDebug(string: "clearpara")
    }
    ////////////////////////////////////////////////
    func savepara_init() {
        let userT = UserDefaults()
        for (key, value) in initValue {
//            print ("\(key):\(value)")
            userT.set(value, forKey: key)
            userT.synchronize()
        }
        LogDebug(string: "savepara_init")
    }
    ////////////////////////////////////////////////
    func savepara() {
        let userT = UserDefaults()
        for (key, value) in saveValue {
//            print ("\(key):\(value)")
            userT.set(value, forKey: key)
            userT.synchronize()
        }
        LogDebug(string: "savepara")
    }
    ////////////////////////////////////////////////
    func savepara_one(key: String, value: Int) {
        let userT = UserDefaults()
        userT.set(value, forKey: key)
        userT.synchronize()
//        LogDebug(string: "savepara one")
    }
    ////////////////////////////////////////////////
    func showpara() {
        for (key, value) in saveValue {
            LogDebug (string: "\(key):\(value)")
        }
    }
    
    
    func save_wheel() {
        for i in 0..<wheel_total {
            saveValue["W\(i)"] = wheel[i]
            savepara_one(key: "W\(i)",value: saveValue["W\(i)"]!)
        }
    }
    
    
    func Test_save() {
        let userKEY = ["PUNIT":22,"TUNIT":22,"HPLIMIT":22,"LPLIMIT":26]
        let userT = UserDefaults()
        for (key, value) in userKEY {
            print ("\(key):\(value)")
            userT.set(value, forKey: key)
            userT.synchronize()
        }
    }
////////////////////////////////////////////////////////////////////////////
    

    
    
////////////////////////////////////////////////////////////////////////////
    @IBAction func btn_car_click(_ sender: Any) {
        if debug_flag == true {
            if rxlog_flag == false{
                rxlog_flag = true
                txt_rx.isHidden = false
            } else {
                rxlog_flag = false
                txt_rx.isHidden = true
            }
        } else {
        }
    }
    ////////////////////////////////////////////////
    @IBAction func btn_logo_click(_ sender: Any) {
//        beep_enable(times: 2)
//        noty_test()
//        ShowNoty_Alarm(wheel: 3,type: 1)
    }
    @IBAction func btn_ant_click(_ sender: Any) {
//        savepara()
//        flash_ant_flag = true
//        Disable_Flash_wheel()
    }
    ////////////////////////////////////////////////
    func SetBtn_longpress() {
        for i in 0..<wheelButton.count {
            let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.longPress(sender:)))
            lpgr.minimumPressDuration = 1.5
            wheelButton[i].addGestureRecognizer(lpgr)
            wheelButton[i].tag = i
        }
    }
    @objc func longPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
//            print("\(sender)")
//            print("\(String(describing: sender.view?.tag))")
//            print("\(String(describing: sender.view))")
            switch sender.view?.tag {
            case 0?:
                LogDebug(string: "Optional(0)")
            case 1?:
                LogDebug(string: "Optional(1)")
            case 2?:
                LogDebug(string: "Optional(2)")
            case 3?:
                LogDebug(string: "Optional(3)")
            default:
                LogDebug(string: "none")
            }
            LogDebug(string: "longPress")
            if CHwheel_flag == false {
                CHwheel_flag = true
                flash_wheel_cnt = 0
                jumpwheel = (sender.view?.tag)!
                Enable_Flash_wheel(wheel: jumpwheel)
            }
        }
    }
    @IBAction func btn_wheel0_click(_ sender: Any) {
        CheckCHwheel(newwheel: (sender as AnyObject).tag)
    }
    @IBAction func btn_wheel1_click(_ sender: Any) {
        CheckCHwheel(newwheel: (sender as AnyObject).tag)
    }
    @IBAction func btn_wheel2_click(_ sender: Any) {
        CheckCHwheel(newwheel: (sender as AnyObject).tag)
    }
    @IBAction func btn_wheel3_click(_ sender: Any) {
        CheckCHwheel(newwheel: (sender as AnyObject).tag)
    }
    ////////////////////////////////////////////////
    @IBAction func btn_status_click(_ sender: Any) {
//        checkpara()
//        flash_ant_flag = false
    }
    ////////////////////////////////////////////////
    @IBAction func btn_voice_click(_ sender: Any) {
        if !(view_setting_flag == true) {
            check_view_voice()
        }
    }
    ////////////////////////////////////////////////
    @IBAction func btn_setting_click(_ sender: Any) {
        if !(view_voice_flag == true) {
            check_view_setting()
        }
    }
    ////////////////////////////////////////////////
    @IBAction func btn_about_click(_ sender: Any) {
        if !((view_voice_flag == true) || (view_setting_flag == true)) == true {
            show_view_about()
        }
    }
    
////////////////////////////////////////////////////////////////////////////
    
    @IBAction func slr_PHlimit(_ sender: UISlider) {
//        LogDebug(string: String(sender.value))
//        LogDebug(string: String(format: "%.0f", (sender.value)))
//        LogDebug(string: String(Int(floor(sender.value))))
        let slr_value = sender.value
        if slr_value <= Float(saveValue["LPLIMIT"]!) {
            saveValue["HPLIMIT"]! = saveValue["LPLIMIT"]! + 1
        } else {
            saveValue["HPLIMIT"]! = Int(floor(sender.value))
        }
        load_limit_PH()
        savepara_one(key: "HPLIMIT",value: saveValue["HPLIMIT"]!)
    }
    @IBAction func slr_PLlimit(_ sender: UISlider) {
        let slr_value = sender.value
        if slr_value >= Float(saveValue["HPLIMIT"]!) {
            saveValue["LPLIMIT"]! = saveValue["HPLIMIT"]! - 1
        } else {
            saveValue["LPLIMIT"]! = Int(floor(sender.value))
        }
        load_limit_PL()
        savepara_one(key: "LPLIMIT",value: saveValue["LPLIMIT"]!)
    }
    @IBAction func slr_THlimit(_ sender: UISlider) {
        saveValue["HTLIMIT"]! = Int(floor(sender.value))
        load_limit_TH()
        savepara_one(key: "HTLIMIT",value: saveValue["HTLIMIT"]!)
    }
    
    
    @IBAction func btn_viewset_initial_click(_ sender: Any) {
        initial_limit()
        display_setting()
    }
    @IBAction func btn_viewset_close_click(_ sender: Any) {
        check_view_setting()
    }
    @IBAction func btn_viewvoice_close_click(_ sender: Any) {
        check_view_voice()
    }
    @IBAction func btn_viewabout_exit_click(_ sender: Any) {
        close_view_about()
    }
////////////////////////////////////////////////////////////////////////////

    @IBAction func btn_voice_land_click(_ sender: Any) {
        if !(view_setting_flag == true) {
            check_view_voice_land()
        }
    }
    @IBAction func btn_setting_land_click(_ sender: Any) {
        if !(view_voice_flag == true) {
            check_view_setting_land()
        }
    }
    
    
////////////////////////////////////////////////////////////////////////////
    
////////////////////////////////////////////////////////////////////////////
    func CheckCHwheel(newwheel: Int) {
        if CHwheel_flag == true {
            CHwheel_flag = false
            Disable_Flash_wheel()
            
            if newwheel != jumpwheel {
                showToast(message: LS(text: "CHwheelOK"))
                let CHwheel0 = wheel[newwheel]
                let CHwheel1 = wheel[jumpwheel]
                wheel[jumpwheel] = CHwheel0
                wheel[newwheel] = CHwheel1
                save_wheel()
                Enable_FlashValue()
            }
        }
    }

////////////////////////////////////////////////////////////////////////////
    func check_view_voice_land() {
        if view_voice_flag == true {
            view_voice_flag = false
            close_ciew_voice()
        } else {
            view_voice_flag = true
            show_view_voice()
        }
    }
////////////////////////////////////////////////////////////////////////////
    func check_view_voice() {
        if view_voice_flag == true {
            view_voice_flag = false
            close_ciew_voice()
            btnImageChange(sender: btn_status, image: "p_mode_status_1")
            btnImageChange(sender: btn_voice, image: "p_mode_voice_0")
        } else {
            view_voice_flag = true
            show_view_voice()
            btnImageChange(sender: btn_status, image: "p_mode_status_0")
            btnImageChange(sender: btn_voice, image: "p_mode_voice_1")
        }
    }
////////////////////////////////////////////////////////////////////////////
    func show_view_voice() {
        view_voice_flag = true
        
//        view_voice.layer.cornerRadius = 25
//        view_voice_bottomCst.constant = 250
//        UIView.animate(withDuration: 0.3){
//            self.view.layoutIfNeeded()
//        }
        
        
        view_voice.layer.cornerRadius = 25
        if IPAD_flag == true {
            view_voice_bottomCst.constant = 250
        } else {
            if screenPL == true {
                view_voice_bottomCst.constant = 250
            } else {
                view_voice_bottomCst.constant = 30
            }
        }
        UIView.animate(withDuration: 0.3){
            self.view.layoutIfNeeded()
        }
    
    }
////////////////////////////////////////////////////////////////////////////
    func close_ciew_voice() {
        view_voice_flag = false
        
        
        if IPAD_flag == true {
            view_voice_bottomCst.constant = -450
        } else {
            if screenPL == true {
                view_voice_bottomCst.constant = -250
            } else {
                view_voice_bottomCst.constant = -250
            }
        }
        

//        view_voice_bottomCst.constant = -250
        UIView.animate(withDuration: 0.3){
            self.view.layoutIfNeeded()
        }
    }
////////////////////////////////////////////////////////////////////////////
    
    
    
////////////////////////////////////////////////////////////////////////////
    func check_view_setting_land() {
        if view_setting_flag == true {
            display_all()
            view_setting_flag = false
            close_view_setting()
        } else {
            view_setting_flag = true
            show_view_setting()
        }
    }
////////////////////////////////////////////////////////////////////////////
    func check_view_setting() {
        if view_setting_flag == true {
            display_all()
            view_setting_flag = false
            close_view_setting()
            btnImageChange(sender: btn_status, image: "p_mode_status_1")
            btnImageChange(sender: btn_setting, image: "p_mode_set_0")
        } else {
            view_setting_flag = true
            show_view_setting()
            btnImageChange(sender: btn_status, image: "p_mode_status_0")
            btnImageChange(sender: btn_setting, image: "p_mode_set_1")
        }
    }
////////////////////////////////////////////////////////////////////////////
    func show_view_setting() {
        view_setting_flag = true
        
        view_setting.layer.cornerRadius = 25
        if IPAD_flag == true {
            view_setting_bottomCst.constant = 200
        } else {
            if screenPL == true {
                view_setting_bottomCst.constant = 100//200
            } else {
                view_setting_bottomCst.constant = 10
            }
        }
        UIView.animate(withDuration: 0.3){
            self.view.layoutIfNeeded()
        }
    }
////////////////////////////////////////////////////////////////////////////
    func close_view_setting() {
        view_setting_flag = false
        
        if IPAD_flag == true {
            view_setting_bottomCst.constant = -450
        } else {
            if screenPL == true {
                view_setting_bottomCst.constant = -450
            } else {
                view_setting_bottomCst.constant = -300
            }
        }

        UIView.animate(withDuration: 0.3){
            self.view.layoutIfNeeded()
        }
    }
////////////////////////////////////////////////////////////////////////////
    
    
    
    
////////////////////////////////////////////////////////////////////////////
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            switch pickerView.tag {
            case 0:
                return PunitList.count
            case 1:
                return TunitList.count
            case 2:
                return AlarmsoundList.count
            case 3:
                return NotysoundList.count
            default:
                return 0
            }
//            if pickerView.tag == 0 {
//            return PunitList.count
//            } else {
//            return TunitList.count
//            }
        }
        return 0
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            switch pickerView.tag {
            case 0:
                return PunitList[row]
            case 1:
                return TunitList[row]
            case 2:
                return AlarmsoundList[row]
            case 3:
                return NotysoundList[row]
            default:
                return nil
            }
//            if pickerView.tag == 0 {
//                return PunitList[row]
//            } else {
//                return TunitList[row]
//            }
        }
        return nil
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            if pickerView.tag == 0 {
                LogDebug(string: "P UNIT: \(PunitList[row])")
                saveValue["PUNIT"]! = row
                savepara_one(key: "PUNIT",value: saveValue["PUNIT"]!)
                load_limit_PH()
                load_limit_PL()
            } else if pickerView.tag == 1 {
                LogDebug(string: "T UNIT: \(TunitList[row])")
                saveValue["TUNIT"]! = row
                savepara_one(key: "TUNIT",value: saveValue["TUNIT"]!)
                load_limit_TH()
            } else if pickerView.tag == 2 {
                LogDebug(string: "Alarmsound: \(AlarmsoundList[row])")
                saveValue["AlarmSound"]! = row
                savepara_one(key: "AlarmSound",value: saveValue["AlarmSound"]!)
            } else if pickerView.tag == 3 {
                LogDebug(string: "Notysound: \(NotysoundList[row])")
                saveValue["NotySound"]! = row
                savepara_one(key: "NotySound",value: saveValue["NotySound"]!)
            } else {
            }
        }
    }
////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
////////////////////////////////////////////////////////////////////////////
    func show_view_about() {
        viewEffect_about.frame = view.frame
        view.addSubview(viewEffect_about)
        
//        view_about.frame.size = CGSize(width: view.frame.width/3, height: view.frame.height/5)
        view_about.center = view.center
        view_about.layer.borderColor = UIColor.white.cgColor
        view_about.layer.borderWidth = 2
        view_about.layer.cornerRadius = 10
        
        SetBtnTitle(sender: btn_viewabout_exit,text: "OK")
        btn_viewabout_exit.layer.borderColor = UIColor.white.cgColor
        btn_viewabout_exit.layer.borderWidth = 2
        btn_viewabout_exit.layer.cornerRadius = 10
        
        
        txt_about.text = LS(text: "company") + "\n"+"\n" + LS(text: "phone") + "\n"+"\n" + LS(text: "mail") + "\n"+"\n" + LS(text: "web") + "\n"+"\n" + LS(text: "address")
        
        view.addSubview(view_about)
    }
////////////////////////////////////////////////////////////////////////////
    func close_view_about() {
        viewEffect_about.removeFromSuperview()
        view_about.removeFromSuperview()
    }
////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    

    
    
////////////////////////////////////////////////////////////////////////////
    func Enable_Flash_wheel(wheel: Int) {
//        jumpwheel = wheel
        flash_wheel_flag = true
        flash_wheel_up_flag = false
    }
    func Disable_Flash_wheel() {
        flash_wheel_flag = false
        wheel_Cst_Initial()
    }
    func wheel_Cst_Initial() {
        for i in 0..<wheel_total {
            btnCstInitial(sender: wheelbottom_Cst[i], Initial: wheelbottom_Cst_Initial[i])
        }
    }
////////////////////////////////////////////////////////////////////////////
    

////////////////////////////////////////////////////////////////////////////
    func Flash_ant() {
        if flash_ant_flag == true {
            Flashant_cnt = Flashant_cnt + 1
            if Flashant_cnt >= 4 {
                Flashant_cnt = 0
            }
            btnImageChange(sender: btn_ant, image: antbtn[Flashant_cnt])
        }
    }
    func Flash_wheel() {
        if flash_wheel_flag == true {
            if flash_wheel_up_flag == false {
                btnCstChange(sender: wheelbottom_Cst[jumpwheel], Initial: wheelbottom_Cst_Initial[jumpwheel], shift: 10)
                flash_wheel_up_flag = true
            } else {
                btnCstInitial(sender: wheelbottom_Cst[jumpwheel], Initial: wheelbottom_Cst_Initial[jumpwheel])
                flash_wheel_up_flag = false
            }
            
            flash_wheel_cnt = flash_wheel_cnt + 1
            if flash_wheel_cnt >= flash_wheel_cnt_k {
                showToast(message: LS(text: "CHwheelNG"))
                CHwheel_flag = false
                Disable_Flash_wheel()
            }
        }
    }
////////////////////////////////////////////////////////////////////////////
    
    @objc func sound_alarm() {
        if alarmflag2 == true {
            if alarm_cnt >= alarmcnt_k2 {
                alarm_cnt = alarmcnt_k2
                sound_cnt = 0
            } else if alarm_cnt >= alarmcnt_k1 {
                sound_cnt = sound_cnt + 1
                if sound_cnt >= soundcnt_k {
                    if saveValue["AlarmSound"]! == 1 {
                        beep_enable(times: 1)
                    }
                    sound_cnt = 0
                    alarm_cnt = alarm_cnt + 1
                }
            } else {
                sound_cnt = sound_cnt + 1
                if sound_cnt >= soundcnt_k1 {
                    if saveValue["AlarmSound"]! == 1 {
                        beep_enable(times: 2)
                    }
                    sound_cnt = 0
                    alarm_cnt = alarm_cnt + 1
                }
            }
        } else {
            alarm_cnt = alarmcnt_k2
            sound_cnt = 0
        }
    }
    @objc func Falsh_icon() {
//        LogDebug(string: "Falsh_icon")
        Flash_ant()
        Flash_wheel()
    }
    @objc func Falsh_rx() {
        if rxupdate_falg == true {
            
            if FLASH_WHEEL[0] == true {
                if screenPL == true {
                    ReflashW0(i: wheel[0])
                } else {
                    l_ReflashW0(i: wheel[0])
                }
                FLASH_WHEEL[0] = false
            }
            if FLASH_WHEEL[1] == true {
                if screenPL == true {
                    ReflashW1(i: wheel[1])
                } else {
                    l_ReflashW1(i: wheel[1])
                }
                FLASH_WHEEL[1] = false
            }
            if FLASH_WHEEL[2] == true {
                if screenPL == true {
                    ReflashW2(i: wheel[2])
                } else {
                    l_ReflashW2(i: wheel[2])
                }
                FLASH_WHEEL[2] = false
            }
            if FLASH_WHEEL[3] == true {
                if screenPL == true {
                    ReflashW3(i: wheel[3])
                } else {
                    l_ReflashW3(i: wheel[3])
                }
                FLASH_WHEEL[3] = false
            }
            if FLASH_WHEEL[4] == true {
                if screenPL == true {
                    ReflashW4(i: wheel[4])
                } else {
                    l_ReflashW4(i: wheel[4])
                }
                FLASH_WHEEL[4] = false
            }
            if FLASH_WHEEL[5] == true {
                if screenPL == true {
                    ReflashW5(i: wheel[5])
                } else {
                    l_ReflashW5(i: wheel[5])
                }
                FLASH_WHEEL[5] = false
            }
            
            checkalarm()
            //        Disable_Timer2()
            LogDebug(string: "FLASH DONE!")

            rxupdate_falg = false
        }
    }
////////////////////////////////////////////////////////////////////////////
    func ReflashW0(i: Int) {
        if RX_flag[i] == true {
            btnImageChange(sender: wheelButton[0],image: load_wheelimage_on(wheel: i))
        } else {
            btnImageChange(sender: wheelButton[0],image: load_wheelimage_off(wheel: i))
        }
        if BT_flag[i] == true {
            btnImageChange(sender: btButton[0],image: load_btimage(status: true))
        } else {
            btnImageChange(sender: btButton[0],image: load_btimage(status: false))
        }
        if PressLFlag[i] == true {
            btnImageChange(sender: pressButton[0],image: load_pressimage(status: "LOW"))
            SetLabColor(sender: PvalueLabel[0], color: UIColor.red)
        } else if PressHFlag[i] == true {
            btnImageChange(sender: pressButton[0],image: load_pressimage(status: "HIGH"))
            SetLabColor(sender: PvalueLabel[0], color: UIColor.red)
        } else {
            btnImageChange(sender: pressButton[0],image: load_pressimage(status: "NORMAL"))
            SetLabColor(sender: PvalueLabel[0], color: UIColor.white)
        }
        if TempHFlag[i] == true {
            btnImageChange(sender: tempButton[0],image: load_tempimage(status: "HIGH"))
            SetLabColor(sender: TvalueLabel[0], color: UIColor.red)
        } else {
            btnImageChange(sender: tempButton[0],image: load_tempimage(status: "NORMAL"))
            SetLabColor(sender: TvalueLabel[0], color: UIColor.white)
        }
        load_PTvalue(wheel: i)
        SetLabTitle(sender: lab_value_P0,text: String(PressDataS[i]))
        SetLabTitle(sender: lab_value_T0,text: String(Int(TempDataS[i])))
    }
    func ReflashW1(i: Int) {
        if RX_flag[i] == true {
            btnImageChange(sender: wheelButton[1],image: load_wheelimage_on(wheel: i))
        } else {
            btnImageChange(sender: wheelButton[1],image: load_wheelimage_off(wheel: i))
        }
        if BT_flag[i] == true {
            btnImageChange(sender: btButton[1],image: load_btimage(status: true))
        } else {
            btnImageChange(sender: btButton[1],image: load_btimage(status: false))
        }
        if PressLFlag[i] == true {
            btnImageChange(sender: pressButton[1],image: load_pressimage(status: "LOW"))
            SetLabColor(sender: PvalueLabel[1], color: UIColor.red)
        } else if PressHFlag[i] == true {
            btnImageChange(sender: pressButton[1],image: load_pressimage(status: "HIGH"))
            SetLabColor(sender: PvalueLabel[1], color: UIColor.red)
        } else {
            btnImageChange(sender: pressButton[1],image: load_pressimage(status: "NORMAL"))
            SetLabColor(sender: PvalueLabel[1], color: UIColor.white)
        }
        if TempHFlag[i] == true {
            btnImageChange(sender: tempButton[1],image: load_pressimage(status: "HIGH"))
            SetLabColor(sender: TvalueLabel[1], color: UIColor.red)
        } else {
            btnImageChange(sender: tempButton[1],image: load_pressimage(status: "NORMAL"))
            SetLabColor(sender: TvalueLabel[1], color: UIColor.white)
        }
        load_PTvalue(wheel: i)
        SetLabTitle(sender: lab_value_P1,text: String(PressDataS[i]))
        SetLabTitle(sender: lab_value_T1,text: String(Int(TempDataS[i])))
    }
    func ReflashW2(i: Int) {
        if RX_flag[i] == true {
            btnImageChange(sender: wheelButton[2],image: load_wheelimage_on(wheel: i))
        } else {
            btnImageChange(sender: wheelButton[2],image: load_wheelimage_off(wheel: i))
        }
        if BT_flag[i] == true {
            btnImageChange(sender: btButton[2],image: load_btimage(status: true))
        } else {
            btnImageChange(sender: btButton[2],image: load_btimage(status: false))
        }
        if PressLFlag[i] == true {
            btnImageChange(sender: pressButton[2],image: load_pressimage(status: "LOW"))
            SetLabColor(sender: PvalueLabel[2], color: UIColor.red)
        } else if PressHFlag[i] == true {
            btnImageChange(sender: pressButton[2],image: load_pressimage(status: "HIGH"))
            SetLabColor(sender: PvalueLabel[2], color: UIColor.red)
        } else {
            btnImageChange(sender: pressButton[2],image: load_pressimage(status: "NORMAL"))
            SetLabColor(sender: PvalueLabel[2], color: UIColor.white)
        }
        if TempHFlag[i] == true {
            btnImageChange(sender: tempButton[2],image: load_pressimage(status: "HIGH"))
            SetLabColor(sender: TvalueLabel[2], color: UIColor.red)
        } else {
            btnImageChange(sender: tempButton[2],image: load_pressimage(status: "NORMAL"))
            SetLabColor(sender: TvalueLabel[2], color: UIColor.white)
        }
        load_PTvalue(wheel: i)
        SetLabTitle(sender: lab_value_P2,text: String(PressDataS[i]))
        SetLabTitle(sender: lab_value_T2,text: String(Int(TempDataS[i])))
    }
    func ReflashW3(i: Int) {
        if RX_flag[i] == true {
            btnImageChange(sender: wheelButton[3],image: load_wheelimage_on(wheel: i))
        } else {
            btnImageChange(sender: wheelButton[3],image: load_wheelimage_off(wheel: i))
        }
        if BT_flag[i] == true {
            btnImageChange(sender: btButton[3],image: load_btimage(status: true))
        } else {
            btnImageChange(sender: btButton[3],image: load_btimage(status: false))
        }
        if PressLFlag[i] == true {
            btnImageChange(sender: pressButton[3],image: load_pressimage(status: "LOW"))
            SetLabColor(sender: PvalueLabel[3], color: UIColor.red)
        } else if PressHFlag[i] == true {
            btnImageChange(sender: pressButton[3],image: load_pressimage(status: "HIGH"))
            SetLabColor(sender: PvalueLabel[3], color: UIColor.red)
        } else {
            btnImageChange(sender: pressButton[3],image: load_pressimage(status: "NORMAL"))
            SetLabColor(sender: PvalueLabel[3], color: UIColor.white)
        }
        if TempHFlag[i] == true {
            btnImageChange(sender: tempButton[3],image: load_pressimage(status: "HIGH"))
            SetLabColor(sender: TvalueLabel[3], color: UIColor.red)
        } else {
            btnImageChange(sender: tempButton[3],image: load_pressimage(status: "NORMAL"))
            SetLabColor(sender: TvalueLabel[3], color: UIColor.white)
        }
        load_PTvalue(wheel: i)
        SetLabTitle(sender: lab_value_P3,text: String(PressDataS[i]))
        SetLabTitle(sender: lab_value_T3,text: String(Int(TempDataS[i])))
    }
    func ReflashW4(i: Int) {
        
    }
    func ReflashW5(i: Int) {
        
    }
    func l_ReflashW0(i: Int) {
        
    }
    func l_ReflashW1(i: Int) {
        
    }
    func l_ReflashW2(i: Int) {
        
    }
    func l_ReflashW3(i: Int) {
        
    }
    func l_ReflashW4(i: Int) {
        
    }
    func l_ReflashW5(i: Int) {
        
    }
    
    
    
    
////////////////////////////////////////////////////////////////////////////
    func load_PTvalue(wheel: Int) {
        PressDataS[wheel] = PutPointN(value: Double(PressData[wheel]) * Punit_k[(saveValue["PUNIT"])!],bit: PressPoint[(saveValue["PUNIT"])!])
        
        if (saveValue["TUNIT"])! == 1 {
            TempDataS[wheel] = PutPointN(value: (Double(TempData[wheel]) * Tunit_k0) + Double(Tunit_k1), bit: PressPoint[(saveValue["TUNIT"])!])
        } else {
            TempDataS[wheel] = PutPointN(value: Double(TempData[wheel]), bit: PressPoint[(saveValue["TUNIT"])!])
        }
    }
////////////////////////////////////////////////////////////////////////////
    
    
    
    
////////////////////////////////////////////////////////////////////////////
    func Enable_TYREDOG() {
        BleSend(message: TX_TC241)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
////////////////////////////////////////////////////////////////////////////
    //初始 Button CST Layout
    func btnCstInitial(sender: NSLayoutConstraint,Initial: Int){
        sender.constant = CGFloat(Initial)
//        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5){
            self.view.layoutIfNeeded()
        }
    }
////////////////////////////////////////////////////////////////////////////
    //改變Button CST Layout
    func btnCstChange(sender: NSLayoutConstraint,Initial: Int, shift: Int){
        sender.constant = CGFloat(Initial + shift)
//        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5){
            self.view.layoutIfNeeded()
        }
    }
////////////////////////////////////////////////////////////////////////////
    //改變Imageview backgroundimage
    func ImgViewImageChange(sender: UIImageView,image: String){
        sender.image = UIImage(named: image)
    }
////////////////////////////////////////////////////////////////////////////
    //改變Button backgroundimage
    func btnImageChange(sender: UIButton,image: String){
        sender.setBackgroundImage(UIImage(named: image), for: UIControlState.normal)
    }
////////////////////////////////////////////////////////////////////////////
    //改變Button Title
    func SetBtnTitle(sender: UIButton,text: String){
        sender.setTitle(NSLocalizedString(text, comment: ""), for: UIControlState.normal)
    }
////////////////////////////////////////////////////////////////////////////
    //改變Label Title
    func SetLabTitle(sender: UILabel,text: String){
        sender.text = text
    }
////////////////////////////////////////////////////////////////////////////
    //改變Label Title Coloe
    func SetLabColor(sender: UILabel,color: UIColor){
        sender.textColor = color
    }
    ////////////////////////////////////////////////////////////////////////////
    //Local String
    func LS(text: String) ->String {
        return NSLocalizedString(text, comment: "")
    }
////////////////////////////////////////////////////////////////////////////
    
    
    
////////////////////////////////////////////////////////////////////////////
    func sound_load(file: String,times: Int) {
        let soundPath = Bundle.main.path(forResource: file, ofType: "wav")
        
        do {
            soundplayer = try AVAudioPlayer(contentsOf: NSURL.fileURL(withPath: soundPath!))
            soundplayer.numberOfLoops = times
        } catch {
            LogDebug(string: "Sound Path Error!")
        }
    }
    
    func beep_enable(times: Int) {
        sound_load(file: "beep",times: times)
        soundplayer.play()
    }
    func alarm_enable(sound: String, times: Int) {
        sound_load(file: sound.replacingOccurrences(of: ".wav", with: ""),times: times)
        soundplayer.play()
    }
////////////////////////////////////////////////////////////////////////////
    
    
    
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        vibration()
    }
    
    
    func vibration() {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
    }
    
    
    
////////////////////////////////////////////////////////////////////////////
    func PutPointN(value: Double, bit: Int) -> Double {
        let number = Double((lround(value * (pow(10, Double(bit))))))/(pow(10, Double(bit)))
        return number
    }
////////////////////////////////////////////////////////////////////////////
    
    

////////////////////////////////////////////////////////////////////////////
    func noty_test() {
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            content.title = "TITLE"
            content.subtitle = "SUBTITLE"
            content.body = "BODY"
            content.badge = 5
            content.sound = UNNotificationSound.default()
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            
            let request = UNNotificationRequest(identifier: "notiy1", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        } else {
            //            let notification = UILocalNotification()
            //            notification.fireDate = NSDate(TimeIntervalSinceNow: 5) as Date
            showToast(message: "noty message!")
        }
    }
////////////////////////////////////////////////////////////////////////////
    func ShowNoty_Alarm(wheel: Int, type: Int) {
        vibration()
        
        settitle = LS(text: alarmtltle[type])
        subtitle = ""
        if wheel_total > 4 {
            icon = alarmicon6[wheel]
            body = LS(text: alarmwheel6[wheel]) + LS(text: alarmtype0[type]) + LS(text: alarmtype1[type])
        } else {
            icon = alarmicon[wheel]
            body = LS(text: alarmwheel[wheel]) + LS(text: alarmtype0[type]) + LS(text: alarmtype1[type])
        }
        switch type {
        case 0:
            sound = alarmsound_p[wheel]
        case 1:
            sound = alarmsound_p[wheel]
        case 2:
            sound = alarmsound_t[wheel]
        case 3:
            sound = alarmsound_s[wheel]
        default:
            sound = "default"
        }
        if saveValue["NotySound"]! == 0 {
            sound = "default"
        }
        
        ShowNoty(notiyID: wheel,TITLE: settitle, SUBTITLE: subtitle, BODY: body, Icon: icon, sound: sound)
    }
////////////////////////////////////////////////////////////////////////////
    func ShowNoty(notiyID: Int,TITLE: String, SUBTITLE: String, BODY: String, Icon: String, sound: String) {
        if #available(iOS 10.0, *) {

            /*
            NotyAlarm_cnt = NotyAlarm_cnt + 1
            let content = UNMutableNotificationContent()
            content.title = TITLE
            content.subtitle = SUBTITLE
            content.body = BODY
            content.badge = NotyAlarm_cnt as NSNumber
            if sound == "default" {
                content.sound = UNNotificationSound.default()
            } else {
                content.sound = UNNotificationSound(named: sound)
            }
            
            let imageURL = Bundle.main.url(forResource: Icon, withExtension: "png")
            let attachment = try! UNNotificationAttachment(identifier: "", url: imageURL!, options: nil)
            content.attachments = [attachment]
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
            
            let request = UNNotificationRequest(identifier: String(notiyID), content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            */
            
            if sound != "default" {
                alarm_enable(sound: "\(sound)",times: 0)
            }
            
            
        } else {
//            let notification = UILocalNotification()
//            notification.fireDate = date
//            notification.alertTitle = TITLE
//            notification.alertBody = BODY
//            notification.soundName = UILocalNotificationDefaultSoundName
//            UIApplication.shared.scheduledLocalNotifications(notification)
//            showToast(message: BODY)
            if sound != "default" {
                alarm_enable(sound: "\(sound)",times: 0)
            }
        }
    }
////////////////////////////////////////////////////////////////////////////
    

    
////////////////////////////////////////////////////////////////////////////
    //Toast message
    func showToast(message: String){
        
        
        LogDebug(string: Lang_string(str: message)!)
        var para_width = 10
        if Lang_string(str: message)! == "zh-Hant" {
            para_width = 20
        }
        
        
        let toastlable = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - CGFloat(((message.count*para_width))/2),y: self.view.frame.size.height-250, width: CGFloat(message.count*para_width), height: 35))
        toastlable.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastlable.textColor = UIColor.white
        toastlable.textAlignment = .center
        toastlable.font = UIFont(name: "Montserrat-light",size: 12.0)
        toastlable.text = message
        toastlable.alpha = 1.0
        toastlable.layer.cornerRadius = 10
        toastlable.clipsToBounds = true
        self.view.addSubview(toastlable)
        UIView.animate(withDuration: 5.0,delay: 0.1,options: .curveEaseOut,animations: {toastlable.alpha = 0.0},completion: {(iscompleted) in toastlable.removeFromSuperview()})
    }
////////////////////////////////////////////////////////////////////////////
    
    
////////////////////////////////////////////////////////////////////////////
  
    
    
    
//    override var shouldAutorotat: Bool {
//        return false
//    }
    
//    override func support?edinterfaceOrientations() -> UIInterfaceOrientationMask {
//        return .portrait?
//    }
    
    
    
    
    
    
    
    
////////////////////////////////////////////////////////////////////////////
    func Lang_string(str: String) -> String? {
        let tagSchemes = [NSLinguisticTagScheme.language]
        let tagger = NSLinguisticTagger(tagSchemes: tagSchemes, options: 0)
        tagger.string = str
        let lang = tagger.tag(at: 0, scheme: NSLinguisticTagScheme.language, tokenRange: nil, sentenceRange: nil)
        return lang.map { $0.rawValue }
    }
    
    
////////////////////////////////////////////////////////////////////////////
    func LogDebug(string: String) {
        if (debug_flag == true) {
            print("LogDebug > " + string)
        }
    }
    func LogTimeDebug(string: String) {
        if (debug_flag == true) {
            NSLog("LogDebug > " + string)
        }
    }
    func Log(string: String) {
        print("Log > " + string)
    }
////////////////////////////////////////////////////////////////////////////
    
    

    
    
    
    
    
    
    
}
