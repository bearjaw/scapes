//
//  MusicAnalysisViewController.swift
//  Scapes
//
//  Created by Max Baumbach on 07/12/2019.
//  Copyright © 2019 Scapes. All rights reserved.
//

import UIKit

final class MusicAnalysisViewController: UIViewController {
    
    private var viewModel: MusicAnalysisViewModelProtocol
    
    // MARK: - Lifecycle begin
    
    init(viewModel: MusicAnalysisViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        title = "Analysis"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavbar()
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
