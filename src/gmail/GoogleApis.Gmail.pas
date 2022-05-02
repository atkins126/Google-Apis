{
  Copyright (C) 2022 by Clever Components

  Author: Sergey Shirokov <admin@clevercomponents.com>

  Website: www.CleverComponents.com

  This file is part of Google API Client Library for Delphi.

  Google API Client Library for Delphi is free software:
  you can redistribute it and/or modify it under the terms of
  the GNU Lesser General Public License version 3
  as published by the Free Software Foundation and appearing in the
  included file COPYING.LESSER.

  Google API Client Library for Delphi is distributed in the hope
  that it will be useful, but WITHOUT ANY WARRANTY; without even the
  implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  See the GNU Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public License
  along with Json Serializer. If not, see <http://www.gnu.org/licenses/>.

  The current version of Google API Client Library for Delphi needs for
  the non-free library Clever Internet Suite. This is a drawback,
  and we suggest the task of changing
  the program so that it does the same job without the non-free library.
  Anyone who thinks of doing substantial further work on the program,
  first may free it from dependence on the non-free library.
}

unit GoogleApis.Gmail;

interface

uses
  System.Classes, System.SysUtils, System.Contnrs, GoogleApis, GoogleApis.Gmail.Data;

type
  TGmailResource = class
  strict private
    FService: TService;
  public
    constructor Create(AService: TService);

    property Service: TService read FService;
  end;

  TLabelsListRequest = class(TServiceRequest<TLabels>)
  strict private
    FUserId: string;
  public
    constructor Create(AService: TService; const AUserId: string);

    function Execute: TLabels; override;

    property UserId: string read FUserId;
  end;

  TLabelsGetRequest = class(TServiceRequest<TLabel>)
  strict private
    FUserId: string;
    FId: string;
  public
    constructor Create(AService: TService; const AUserId, AId: string);

    function Execute: TLabel; override;

    property UserId: string read FUserId;
    property Id: string read FId;
  end;

  TLabelsCreateRequest = class(TServiceRequest<TLabel>)
  strict private
    FUserId: string;
    FContent: TLabel;
  public
    constructor Create(AService: TService; const AUserId: string; AContent: TLabel);
    destructor Destroy; override;

    function Execute: TLabel; override;

    property UserId: string read FUserId;
    property Content: TLabel read FContent;
  end;

  TLabelsDeleteRequest = class(TServiceRequest<Boolean>)
  strict private
    FUserId: string;
    FId: string;
  public
    constructor Create(AService: TService; const AUserId, AId: string);

    function Execute: Boolean; override;

    property UserId: string read FUserId;
    property Id: string read FId;
  end;

  TLabelsPatchRequest = class(TServiceRequest<TLabel>)
  strict private
    FUserId: string;
    FId: string;
    FContent: TLabel;
  public
    constructor Create(AService: TService; const AUserId, AId: string; AContent: TLabel);
    destructor Destroy; override;

    function Execute: TLabel; override;

    property UserId: string read FUserId;
    property Id: string read FId;
    property Content: TLabel read FContent;
  end;

  TLabelsUpdateRequest = class(TLabelsPatchRequest)
  public
    function Execute: TLabel; override;
  end;

  TLabelsResource = class(TGmailResource)
  public
    function Create_(const AUserId: string; AContent: TLabel): TLabelsCreateRequest; virtual;
    function Delete(const AUserId, AId: string): TLabelsDeleteRequest;
    function Get(const AUserId, AId: string): TLabelsGetRequest; virtual;
    function List(const AUserId: string): TLabelsListRequest; virtual;
    function Patch(const AUserId, AId: string; AContent: TLabel): TLabelsPatchRequest; virtual;
    function Update(const AUserId, AId: string; AContent: TLabel): TLabelsUpdateRequest; virtual;
  end;

  TUsersResource = class(TGmailResource)
  strict private
    FLabels: TLabelsResource;

    function GetLabels: TLabelsResource;
  strict protected
    function CreateLabels: TLabelsResource; virtual;
  public
    constructor Create(AService: TService);
    destructor Destroy; override;

    //property Drafts
    //property History
    property Labels: TLabelsResource read GetLabels;
    //property Messages
    //property Settings
    //property Threads
  end;

  TGmailService = class(TService)
  strict private
    FUsers: TUsersResource;

    function GetUsers: TUsersResource;
  strict protected
    function CreateUsers: TUsersResource; virtual;
  public
    constructor Create(AInitializer: TServiceInitializer);
    destructor Destroy; override;

    property Users: TUsersResource read GetUsers;
  end;

const
  //Available OAuth 2.0 scopes for use with the Gmail API.

  //Read, compose, send, and permanently delete all your email from Gmail
  MailGoogleCom = 'https://mail.google.com/';

  //Manage drafts and send emails
  GmailCompose = 'https://www.googleapis.com/auth/gmail.compose';

  //Insert mail into your mailbox
  GmailInsert = 'https://www.googleapis.com/auth/gmail.insert';

  //Manage mailbox labels
  GmailLabels = 'https://www.googleapis.com/auth/gmail.labels';

  //View your email message metadata such as labels and headers, but not the email body
  GmailMetadata = 'https://www.googleapis.com/auth/gmail.metadata';

  //View and modify but not delete your email
  GmailModify = 'https://www.googleapis.com/auth/gmail.modify';

  //View your email messages and settings
  GmailReadonly = 'https://www.googleapis.com/auth/gmail.readonly';

  //Send email on your behalf
  GmailSend = 'https://www.googleapis.com/auth/gmail.send';

  //Manage your basic mail settings
  GmailSettingsBasic = 'https://www.googleapis.com/auth/gmail.settings.basic';

  //Manage your sensitive mail settings, including who can manage your mail
  GmailSettingsSharing = 'https://www.googleapis.com/auth/gmail.settings.sharing';

implementation

{ TGmailService }

constructor TGmailService.Create(AInitializer: TServiceInitializer);
begin
  inherited Create(AInitializer);
  FUsers := nil;
end;

function TGmailService.CreateUsers: TUsersResource;
begin
  Result := TUsersResource.Create(Self);
end;

destructor TGmailService.Destroy;
begin
  FreeAndNil(FUsers);
  inherited Destroy();
end;

function TGmailService.GetUsers: TUsersResource;
begin
  if (FUsers = nil) then
  begin
    FUsers := CreateUsers();
  end;
  Result := FUsers;
end;

{ TGmailResource }

constructor TGmailResource.Create(AService: TService);
begin
  inherited Create();
  FService := AService;
end;

{ TUsersResource }

constructor TUsersResource.Create(AService: TService);
begin
  inherited Create(AService);
  FLabels := nil;
end;

function TUsersResource.CreateLabels: TLabelsResource;
begin
  Result := TLabelsResource.Create(Service);
end;

destructor TUsersResource.Destroy;
begin
  FreeAndNil(FLabels);
  inherited Destroy();
end;

function TUsersResource.GetLabels: TLabelsResource;
begin
  if (FLabels = nil) then
  begin
    FLabels := CreateLabels();
  end;
  Result := FLabels;
end;

{ TLabelsResource }

function TLabelsResource.Create_(const AUserId: string; AContent: TLabel): TLabelsCreateRequest;
begin
  Result := TLabelsCreateRequest.Create(Service, AUserId, AContent);
end;

function TLabelsResource.Delete(const AUserId, AId: string): TLabelsDeleteRequest;
begin
  Result := TLabelsDeleteRequest.Create(Service, AUserId, AId);
end;

function TLabelsResource.Get(const AUserId, AId: string): TLabelsGetRequest;
begin
  Result := TLabelsGetRequest.Create(Service, AUserId, AId);
end;

function TLabelsResource.List(const AUserId: string): TLabelsListRequest;
begin
  Result := TLabelsListRequest.Create(Service, AUserId);
end;

function TLabelsResource.Patch(const AUserId, AId: string; AContent: TLabel): TLabelsPatchRequest;
begin
  Result := TLabelsPatchRequest.Create(Service, AUserId, AId, AContent);
end;

function TLabelsResource.Update(const AUserId, AId: string; AContent: TLabel): TLabelsUpdateRequest;
begin
  Result := TLabelsUpdateRequest.Create(Service, AUserId, AId, AContent);
end;

{ TLabelsListRequest }

constructor TLabelsListRequest.Create(AService: TService; const AUserId: string);
begin
  inherited Create(AService);
  FUserId := AUserId;
end;

function TLabelsListRequest.Execute: TLabels;
var
  response: string;
  params: THttpRequestParameterList;
begin
  params := THttpRequestParameterList.Create();
  try
    response := Service.Initializer.HttpClient.Get('https://gmail.googleapis.com/gmail/v1/users/' + UserId + '/labels', params);
    Result := TLabels(Service.Initializer.JsonSerializer.JsonToObject(TLabels, response));
  finally
    params.Free();
  end;
end;

{ TLabelsGetRequest }

constructor TLabelsGetRequest.Create(AService: TService; const AUserId, AId: string);
begin
  inherited Create(AService);

  FUserId := AUserId;
  FId := AId;
end;

function TLabelsGetRequest.Execute: TLabel;
var
  response: string;
  params: THttpRequestParameterList;
begin
  params := THttpRequestParameterList.Create();
  try
    response := Service.Initializer.HttpClient.Get('https://gmail.googleapis.com/gmail/v1/users/' + UserId + '/labels/' + Id, params);
    Result := TLabel(Service.Initializer.JsonSerializer.JsonToObject(TLabel, response));
  finally
    params.Free();
  end;
end;

{ TLabelsCreateRequest }

constructor TLabelsCreateRequest.Create(AService: TService; const AUserId: string; AContent: TLabel);
begin
  inherited Create(AService);

  FUserId := AUserId;
  FContent := AContent;
end;

destructor TLabelsCreateRequest.Destroy;
begin
  FContent.Free();
  inherited Destroy();
end;

function TLabelsCreateRequest.Execute: TLabel;
var
  request, response: string;
  params: THttpRequestParameterList;
begin
  params := THttpRequestParameterList.Create();
  try
    request := Service.Initializer.JsonSerializer.ObjectToJson(Content);

    response := Service.Initializer.HttpClient.Post(
      'https://gmail.googleapis.com/gmail/v1/users/' + UserId + '/labels', params, request);

    Result := TLabel(Service.Initializer.JsonSerializer.JsonToObject(TLabel, response));
  finally
    params.Free();
  end;
end;

{ TLabelsDeleteRequest }

constructor TLabelsDeleteRequest.Create(AService: TService; const AUserId, AId: string);
begin
  inherited Create(AService);

  FUserId := AUserId;
  FId := AId;
end;

function TLabelsDeleteRequest.Execute: Boolean;
begin
  Service.Initializer.HttpClient.Delete(
    'https://gmail.googleapis.com/gmail/v1/users/' + UserId + '/labels/' + Id);
  Result := True;
end;

{ TLabelsPatchRequest }

constructor TLabelsPatchRequest.Create(AService: TService; const AUserId, AId: string; AContent: TLabel);
begin
  inherited Create(AService);

  FUserId := AUserId;
  FId := AId;
  FContent := AContent;
end;

destructor TLabelsPatchRequest.Destroy;
begin
  FContent.Free();
  inherited Destroy();
end;

function TLabelsPatchRequest.Execute: TLabel;
var
  request, response: string;
  params: THttpRequestParameterList;
begin
  params := THttpRequestParameterList.Create();
  try
    request := Service.Initializer.JsonSerializer.ObjectToJson(Content);

    response := Service.Initializer.HttpClient.Patch(
      'https://gmail.googleapis.com/gmail/v1/users/' + UserId + '/labels/' + Id, params, request);

    Result := TLabel(Service.Initializer.JsonSerializer.JsonToObject(TLabel, response));
  finally
    params.Free();
  end;
end;

{ TLabelsUpdateRequest }

function TLabelsUpdateRequest.Execute: TLabel;
var
  request, response: string;
  params: THttpRequestParameterList;
begin
  params := THttpRequestParameterList.Create();
  try
    request := Service.Initializer.JsonSerializer.ObjectToJson(Content);

    response := Service.Initializer.HttpClient.Put(
      'https://gmail.googleapis.com/gmail/v1/users/' + UserId + '/labels/' + Id, params, request);

    Result := TLabel(Service.Initializer.JsonSerializer.JsonToObject(TLabel, response));
  finally
    params.Free();
  end;
end;

end.
