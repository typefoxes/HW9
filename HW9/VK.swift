

import UIKit
import VK_ios_sdk

class VK: UIViewController {
    
    let picker = UIImagePickerController()
    let sdkInstance = VKSdk.initialize(withAppId: "51433766")
    let SCOPE = ["friends","email","wall","photos"]
    
    @objc func openPicker() { present(picker, animated: true, completion: nil) }
    
    @IBOutlet weak var ImagePost: UIImageView!
    @IBOutlet weak var AddPostButton: UIButton!
    @IBOutlet weak var VKLoginButton: UIButton!
    
    @IBAction func AddPostAction(_ sender: UIButton) {
        let shareDialog = VKShareDialogController()
        shareDialog.requestedScope = SCOPE
        shareDialog.text = "Exampale"
        shareDialog.vkImages = ["-60479154_333497085"]
        
        let image = VKUploadImage(image: ImagePost.image, andParams: VKImageParameters.jpegImage(withQuality: 1.0))
        shareDialog.uploadImages = [image!]
        shareDialog.shareLink = VKShareLink(title: "My profile Git", link: URL(string: "https://github.com/typefoxes"))
        self.present(shareDialog, animated: true)
        
        shareDialog.completionHandler = { VKShareDialogController, result in
            if VKSdk.accessToken()?.accessToken != nil {
                print("\n~ ~ ~ JSON всех постов на стене: ~ ~ ~")
                print("https://api.vk.com/method/wall.get?&access_token=\(VKSdk.accessToken().accessToken!)&v=5.84")
            }
                self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func VKLogin(_ sender: UIButton) {
        VKSdk.wakeUpSession(SCOPE, complete: { state, error in
            if state == .authorized {
                print("\nForces logout")
                VKSdk.forceLogout()
                self.VKLoginButton.setTitleColor(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), for: .normal)
                        self.VKLoginButton.setTitle("Войти в VK", for: .normal)
                        self.AddPostButton.isEnabled = false
                } else {
                        print("Нажата кнопка авторизации")
                        VKSdk.authorize(self.SCOPE, with: .disableSafariController)
                }
            })
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sdkInstance?.register(self)
        sdkInstance?.uiDelegate = self
        VKSdk.wakeUpSession(SCOPE, complete: { state, error in
            if state == .authorized {
                print("Пользователь авторизован")
                print("https://vk.com/id\(VKSdk.accessToken().userId!)")
                print()
                self.JSONnewsfeed()
    } else {
            print("Пользователь не авторизован")
            if error != nil { print("Error: \(error!.localizedDescription)") }
            }
        })
                
                self.picker.delegate = self
                self.ImagePost.isUserInteractionEnabled = true
                let tap = UITapGestureRecognizer(target: self, action: #selector(openPicker))
                self.ImagePost.addGestureRecognizer(tap)
            }

            func JSONnewsfeed() {

                print("JSON новостной ленты:")
                print("https://api.vk.com/method/newsfeed.get?filters=post, photo&access_token=\(VKSdk.accessToken().accessToken!)&v=5.110")
                self.AddPostButton.isEnabled = true
                self.VKLoginButton.setTitle("Выйти", for: .normal)
            }
        }

        extension VK: VKSdkDelegate, VKSdkUIDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
            func vkSdkAccessAuthorizationFinished(with result: VKAuthorizationResult!) {
                if result.token != nil {
                    print("Пользователь успешно авторизован")
                    self.JSONnewsfeed()
                } else if result.error != nil {
                    print("Пользователь отменил авторизацию или произошла ошибка")
                }
            }
            
            func vkSdkUserAuthorizationFailed() {
                print("vkSdkUserAuthorizationFailed")
            }
            
            func vkSdkShouldPresent(_ controller: UIViewController!) {
                guard controller != nil else {
                    return print("Ошибка vkSdkShouldPresent")
                }
                self.present(controller, animated: true, completion: {
                    print("Переход в окно авторизации")
                })
            }
            
            func vkSdkNeedCaptchaEnter(_ captchaError: VKError!) {
                print("vkSdkNeedCaptchaEnter")
                let vc = VKCaptchaViewController.captchaControllerWithError(captchaError)
                vc?.present(in: self)
            }

            func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
                if let image = info[.originalImage] as? UIImage {
                    ImagePost.image = image
                }; dismiss(animated: true, completion: nil)
            }
        }
