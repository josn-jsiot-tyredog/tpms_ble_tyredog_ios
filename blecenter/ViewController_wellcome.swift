//
//  ViewController_wellcome.swift
//  blecenter
//
//  Created by JOSN on 2018/5/23.
//  Copyright © 2018年 JOSN. All rights reserved.
//

import UIKit




var timer1_falsh: Timer!

var flash_cnt0 = 0
var flash_cnt = 0
var wellcome_img = ["td_1","td_2","td_3","td_4","td_5","td_6","td_7","td_8","td_9","td_10"]


class ViewController_wellcome: UIViewController {

    
    
    @IBOutlet weak var btn_wellcome: UIButton!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        init_display()
        timer_enable()
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    
    
    
    func timer_enable() {
        Enable_Timer1()

    }
    func timer_disable() {
        Disable_Timer1()

    }
    func Enable_Timer1() {
        timer1_falsh = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(Falsh_icon), userInfo: nil, repeats: true)
//        LogDebug(string: "Enable_Timer1")
    }
    func Disable_Timer1() {
        if timer1_falsh != nil {
            timer1_falsh?.invalidate()
        }
    }
    
    
    
    
    
    @objc func Falsh_icon() {
        flash_cnt0 = flash_cnt0 + 1
        flash_cnt = flash_cnt + 1
        if flash_cnt0 >= (wellcome_img.count+5) {
            Disable_Timer1()
            go2main()
        } else if flash_cnt0 >= wellcome_img.count{
            flash_cnt = wellcome_img.count - 1

        } else {
            btnImageChange(sender: btn_wellcome,image: wellcome_img[flash_cnt])
        }
        

    }
    
    
    func go2main() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "main")
        showDetailViewController(vc!, sender: self)
//        self.dismiss(animated: true, completion:nil)
    }
    
    func init_display() {
        btnImageChange(sender: btn_wellcome,image: wellcome_img[0])
    }
    
    
    
    
    ////////////////////////////////////////////////////////////////////////////
    //改變Button backgroundimage
    func btnImageChange(sender: UIButton,image: String){
        sender.setBackgroundImage(UIImage(named: image), for: UIControlState.normal)
    }
    ////////////////////////////////////////////////////////////////////////////
    
    
}
